resource "aws_key_pair" "wordpress_key_pair" {
  key_name   = "wordpress_key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEAy0a4pC1sB5VIzZi86z/l/b7dDJhQbaT9os7VYycEFEq45KOPuPJ040MqrmTu2oQi+WugZDnxdW3ZgEbwkGVyhCy+8KPEkTetBKaZQAQIwdWvFj/pWuLscyFeZ2zYB19H9fmDVkNSEdvurjxtv7PdDNhdXPtSP/waYxgHmPX5VT8ssn5oASPH4p4v/Agdx9N1a76xVXzUuExw6R8XHGcr7BFsflnFt068/tiHnkcux0A9NRtf3De5ZnWq1I/PgwNC3HC052Etqou6gO07FjCYL8cdIsRWRKlToiPFEnLIBxkmSKWYj8SkVJDJ3y3TTx92BkTNzoAa6VzbXacPp/3RGw== krishna.sarma@smartpipesolutions.com"
}

resource "aws_security_group" "sg-internet-instances" {
  name        = "wordpress-internet-ec2-sg"
  description = "wordpress internet to instances security group"
  vpc_id      = "${aws_vpc.wordpress_vpc.id}"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "mgmt_instance_security_group" {
  name        = "ec2_instance_security_group"
  description = "To allow only connections from the local machine to the EC2 instance."
  vpc_id      = "${aws_vpc.wordpress_vpc.id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["185.23.52.222/32"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["185.23.52.222/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "ec2_instance" {
  ami                         = "ami-0eab3a90fc693af19"
  instance_type               = "t2.micro"
  subnet_id                   = "${aws_subnet.subnet_availability_zone_a.id}"
  associate_public_ip_address = "True"
  vpc_security_group_ids      = ["${aws_security_group.mgmt_instance_security_group.id}", "${aws_security_group.sg-internet-instances.id}"]
  key_name                    = "${aws_key_pair.wordpress_key_pair.key_name}"

  tags = {
    Name = "wordpress_ec2_instance"
  }
}
