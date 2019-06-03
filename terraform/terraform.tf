terraform {
  backend "s3" {
    bucket = "honeyenditsolutions-terraform-qa"
    key    = "terraform.tfstat"
    region = "eu-west-2"
  }
}
