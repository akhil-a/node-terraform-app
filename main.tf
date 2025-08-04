
resource "aws_instance" "bastion_host" {
  ami                    = var.ami_id
  key_name               = "mumbai-key"
  vpc_security_group_ids = [aws_security_group.bastion_sg.id]
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public_subnets[0].id

  tags = {
    "Name" = "${var.project_name}-${var.project_env}-bastion-host"
  }
}


resource "aws_instance" "db_server" {
  ami                    = var.ami_id
  key_name               = "mumbai-key"
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.private_subnets[1].id
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  user_data              = file("db_userdata.sh")

  tags = {
    "Name" = "${var.project_name}-${var.project_env}-dbserver"
  }
}

resource "aws_instance" "nodejsapp" {
  count                  = 2
  ami                    = var.ami_id
  key_name               = "mumbai-key"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.private_subnets[count.index].id
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  user_data              = file("node_app_userdata.sh")

  tags = {
    "Name" = "${var.project_name}-${var.project_env}-webserver"
  }
}


resource "aws_lb" "web-alb" {
  name     = "${var.project_name}${var.project_env}webALB"
  internal = false

  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = aws_subnet.public_subnets[*].id

  enable_deletion_protection = false

  tags = {
    Name = "${var.project_name}-${var.project_env}webALB"
  }
}


resource "aws_lb_target_group" "app_tg" {
  name     = "webALB-app-tg"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = aws_vpc.testvpc.id

  health_check {
    path                = "/health"
    protocol            = "HTTP"
    port                = "8080"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_target_group_attachment" "app_attachment" {
  count            = 2
  target_group_arn = aws_lb_target_group.app_tg.arn
  target_id        = aws_instance.nodejsapp[count.index].id
  port             = 8080
}

resource "aws_lb_listener" "app_listener" {
  load_balancer_arn = aws_lb.web-alb.arn
  port              = 8080
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}


resource "aws_route53_record" "db_record" {
  zone_id = data.aws_route53_zone.my_domain.zone_id
  name    = "dbinstance.${var.domain_name}"
  type    = "A"
  ttl     = 300
  records = [aws_instance.db_server.private_ip]
}


resource "aws_route53_record" "route53-alias" {
  zone_id = data.aws_route53_zone.my_domain.zone_id
  name    = "${var.project_name}-${var.project_env}.${var.domain_name}"
  type    = "A"

  alias {
    name                   = aws_lb.web-alb.dns_name
    zone_id                = aws_lb.web-alb.zone_id
    evaluate_target_health = true
  }
}