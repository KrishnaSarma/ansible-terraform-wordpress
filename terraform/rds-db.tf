resource "aws_security_group" "sg_rds" {
  name        = "wordpress-rds-sg"
  description = "wordpress RDS database security group"
  vpc_id      = "${aws_vpc.wordpress_vpc.id}"

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = ["${aws_security_group.sg-internet-instances.id}", "${aws_security_group.mgmt_instance_security_group.id}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_subnet_group" "rds_wordpress_subnet" {
  name        = "wordpress_rds_subnet_group"
  description = "Terraform RDS subnet group"
  subnet_ids  = ["${aws_subnet.subnet_availability_zone_a.id}", "${aws_subnet.subnet_availability_zone_b.id}", "${aws_subnet.subnet_availability_zone_c.id}"]
}

resource "aws_db_instance" "wp_rds_db" {
  engine                 = "mysql"
  engine_version         = "5.7"
  allocated_storage      = 20
  storage_type           = "gp2"
  instance_class         = "db.t2.micro"
  name                   = "honeyenditsolutionswordpressrds"
  username               = "${var.rds_username}"
  password               = "${var.rds_password}"
  vpc_security_group_ids = ["${aws_security_group.sg_rds.id}"]
  db_subnet_group_name   = "${aws_db_subnet_group.rds_wordpress_subnet.id}"
}
