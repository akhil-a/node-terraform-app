resource "aws_security_group" "bastion_sg" {
  name   = "${var.project_name}-${var.project_env}-bastionSG"
  vpc_id = aws_vpc.testvpc.id
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Name" = "${var.project_name}-${var.project_env}-bastionSG"
  }

}

resource "aws_security_group_rule" "bastion-ingress-rule" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.bastion_sg.id
}

resource "aws_security_group" "web_sg" {
  name   = "${var.project_name}-${var.project_env}-webSG"
  vpc_id = aws_vpc.testvpc.id
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Name" = "${var.project_name}-${var.project_env}-webSG"
  }

}

resource "aws_security_group_rule" "websg-ingress-ssh" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.bastion_sg.id
  security_group_id        = aws_security_group.web_sg.id
}


resource "aws_security_group_rule" "websg-ingress-rules" {
  count                    = length(var.server_ports)
  type                     = "ingress"
  from_port                = var.server_ports[count.index]
  to_port                  = var.server_ports[count.index]
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.alb_sg.id
  security_group_id        = aws_security_group.web_sg.id
}


resource "aws_security_group" "alb_sg" {
  name   = "${var.project_name}-${var.project_env}-albSG"
  vpc_id = aws_vpc.testvpc.id
  tags = {
    "Name" = "${var.project_name}-${var.project_env}-albSG"
  }

}

resource "aws_security_group_rule" "alb-ingress-rules" {
  count             = length(var.server_ports)
  type              = "ingress"
  from_port         = var.server_ports[count.index]
  to_port           = var.server_ports[count.index]
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.alb_sg.id
}

resource "aws_security_group_rule" "alb-egress-rules" {
  count                    = length(var.server_ports)
  type                     = "egress"
  from_port                = var.server_ports[count.index]
  to_port                  = var.server_ports[count.index]
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.web_sg.id
  security_group_id        = aws_security_group.alb_sg.id
}


resource "aws_security_group" "db_sg" {
  name   = "${var.project_name}-${var.project_env}-dbSG"
  vpc_id = aws_vpc.testvpc.id
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    "Name" = "${var.project_name}-${var.project_env}-dbSG"
  }

}


resource "aws_security_group_rule" "dbsg-ingress-ssh" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.bastion_sg.id
  security_group_id        = aws_security_group.db_sg.id
}

resource "aws_security_group_rule" "dbsg-ingress-db" {
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.web_sg.id
  security_group_id        = aws_security_group.db_sg.id
}