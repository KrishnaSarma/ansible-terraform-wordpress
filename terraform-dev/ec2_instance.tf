data "aws_vpc" "wp_vpc" {
  default = "false"

  tags {
    Environment = "prod"
  }
}

data "aws_subnet" "subnet_az_a" {
  vpc_id            = "${data.aws_vpc.wp_vpc.id}"
  availability_zone = "eu-west-2a"
}

data "aws_security_group" "vpc_sg_internet" {
  name   = "*internet*"
  vpc_id = "${data.aws_vpc.wp_vpc.id}"
}

data "aws_security_group" "vpc_sg_mgmt" {
  vpc_id = "${data.aws_vpc.wp_vpc.id}"
  name   = "*_instance_*"
}

resource "aws_s3_bucket" "code_bucket" {
  bucket = "honeyenditsolutions-code-bucket"
  region = "eu-west-2"

  tags {
    Name        = "Wordpress Code Bucket"
    Environment = "${var.environment}"
  }
}

resource "aws_instance" "ec2" {
  ami                         = "ami-0eab3a90fc693af19"
  instance_type               = "t2.micro"
  key_name                    = "wordpress_key"
  associate_public_ip_address = "True"
  vpc_security_group_ids      = ["${data.aws_security_group.vpc_sg_internet.id}", "${data.aws_security_group.vpc_sg_mgmt.id}"]
  subnet_id                   = "${data.aws_subnet.subnet_az_a.id}"

  tags {
    Name = "Wordpress-dev-instance"
  }

  provisioner "local-exec" {
    command = <<EOD
cat << EOF > ../ansible_code/hosts
[dev]    
${aws_instance.ec2.public_ip}
    
[dev:vars]
s3code=${aws_s3_bucket.code_bucket.bucket}
EOF
EOD
  }

  provisioner "local-exec" {
    command = "aws ec2 wait instance-status-ok --instance-ids ${aws_instance.ec2.id} && cd ../ansible_code; ansible-playbook -i hosts -u centos wordpress.yml"
  }
}

resource "aws_ami_from_instance" "wp_custom_ami" {
  name               = "honeyenditsolutions_custom_ami"
  source_instance_id = "${aws_instance.ec2.id}"

  provisioner "local-exec" {
    command = <<EOT
cat <<EOF > ../terraform-prod/user_data/bootstrap.sh
#!/bin/bash
/usr/bin/aws s3 sync s3://${aws_s3_bucket.code_bucket.bucket} /var/www/html/
/bin/touch /var/spool/cron/root
sudo /bin/echo '*/5 * * * * aws s3 sync s3://${aws_s3_bucket.code_bucket.bucket} /var/www/html/' >> /var/spool/cron/root
EOF
EOT
  }

  tags {
    Name = "Wordpress Custom AMI"
  }
}
