terraform {
  backend "s3" {
    bucket = "honeyenditsolutions-terraform-dev"
    key    = "terraform.tfstat"
    region = "eu-west-2"
  }
}
