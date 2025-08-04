
variable "project_name" {
  description = "project name"
  type        = string
}

variable "project_env" {
  description = "project environment"
  type        = string
}

variable "instance_type" {
  description = "t2 micro usually"
  type        = string
}

variable "ami_id" {
  description = "ami id"
  type        = string
}

variable "vcp_cidr_block" {
  description = "cidr block of VPC"
  type        = string
}

variable "domain_name" {
  description = "domain name in route53"
  type        = string
}

variable "enable_nat_gw" {

  description = "Set true to enable nat gw"
  type        = bool
}

variable "server_ports" {
  description = " port list"
  type        = list(any)
}

variable "asg_sizes" {
  type = map(any)

}
