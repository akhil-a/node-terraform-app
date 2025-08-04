provider "aws" {
  region     = "ap-south-1"
  default_tags {
    tags = {
      "Project"     = var.project_name
      "Environment" = var.project_env

    }
  }
}