data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_route53_zone" "my_domain" {
  name         = var.domain_name
  private_zone = false
}
