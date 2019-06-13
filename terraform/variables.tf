variable "aws_region" {
  default = "eu-west-2"
}

variable "environment" {
  default = "prod"
}

variable "application" {
  default = "wordpress"
}

variable "email" {
  default = "krishna.sarma@smartpipesolutions.com"
}

variable "jira_ticket_no" {
  default = "TAS1234"
}

variable "user_name" {
  default = "JMorgan"
}

variable "max_instance_size" {
  default = "3"
}

variable "min_instance_size" {
  default = "1"
}

variable "desired_instance_size" {
  default = "1"
}

variable "rds_username" {
  default = "twpadmin"
}

variable "rds_password" {
  description = "AWS RDS instance password"
  type        = "string"
}
