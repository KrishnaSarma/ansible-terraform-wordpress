# VPC
resource "aws_vpc" "wordpress_vpc" {
  cidr_block           = "10.1.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags {
    Name        = "vpc-${var.aws_region}-${var.environment}-${var.application}"
    Environment = "${var.environment}"
    Owner       = "${var.email}"
    Jira_ticket = "${var.jira_ticket_no}"
  }
}

resource "aws_subnet" "subnet_availability_zone_a" {
  vpc_id            = "${aws_vpc.wordpress_vpc.id}"
  cidr_block        = "10.1.0.0/20"
  availability_zone = "eu-west-2a"

  tags = {
    Name = "subnet_availability_zone_a"
  }
}

resource "aws_subnet" "subnet_availability_zone_b" {
  vpc_id            = "${aws_vpc.wordpress_vpc.id}"
  cidr_block        = "10.1.16.0/20"
  availability_zone = "eu-west-2b"

  tags = {
    Name = "subnet_availability_zone_b"
  }
}

resource "aws_subnet" "subnet_availability_zone_c" {
  vpc_id            = "${aws_vpc.wordpress_vpc.id}"
  cidr_block        = "10.1.32.0/20"
  availability_zone = "eu-west-2c"

  tags = {
    Name = "subnet_availability_zone_c"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.wordpress_vpc.id}"

  tags = {
    Name = "main_gw"
  }
}

resource "aws_route_table" "custom_route_table" {
  vpc_id = "${aws_vpc.wordpress_vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.gw.id}"
  }

  tags = {
    Name = "custom_ig_route_table"
  }
}

resource "aws_route_table_association" "association_a" {
  subnet_id      = "${aws_subnet.subnet_availability_zone_a.id}"
  route_table_id = "${aws_route_table.custom_route_table.id}"
}

resource "aws_route_table_association" "association_b" {
  subnet_id      = "${aws_subnet.subnet_availability_zone_b.id}"
  route_table_id = "${aws_route_table.custom_route_table.id}"
}

resource "aws_route_table_association" "association_c" {
  subnet_id      = "${aws_subnet.subnet_availability_zone_c.id}"
  route_table_id = "${aws_route_table.custom_route_table.id}"
}
