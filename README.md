# ansible-terraform-wordpress

Code that loads a wordpress website in an AWS EC2 instance using Ansible and Terraform

Terraform is used to build the infrastructure-Load Balancer, Security groups, Auto Scaling Group, EC2, S3 and ami.

Ansible is used to configure the built infrastructure- install the appropriate softwares and load wordpress from the S3 bucket.
