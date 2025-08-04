terraform {
  backend "s3" {
    bucket = "terraform-statefiles-akhil10anil"
    key    = "node-terraform-app/terraform.tfstate"
    region = "ap-south-1"
  }
}