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

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_launch_configuration" "wp_asg_launch_config" {
  name_prefix                 = "wordpress-"
  image_id                    = "ami-0eab3a90fc693af19"
  instance_type               = "t2.micro"
  associate_public_ip_address = "True"
  security_groups             = ["${aws_security_group.mgmt_instance_security_group.id}", "${aws_security_group.sg-internet-instances.id}"]
  key_name                    = "${aws_key_pair.wordpress_key_pair.key_name}"
  user_data                   = "${file("user_data/user_data_test.sh")}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "wp_asg" {
  name                 = "wp-autoscaling-group"
  max_size             = "${var.max_instance_size}"
  min_size             = "${var.min_instance_size}"
  desired_capacity     = "${var.desired_instance_size}"
  force_delete         = true
  launch_configuration = "${aws_launch_configuration.wp_asg_launch_config.name}"
  vpc_zone_identifier  = ["${aws_subnet.subnet_availability_zone_a.id}", "${aws_subnet.subnet_availability_zone_b.id}", "${aws_subnet.subnet_availability_zone_c.id}"]
  target_group_arns    = ["${aws_lb_target_group.wordpress_instance_target.arn}"]

  lifecycle {
    create_before_destroy = true
  }

  tag {
    key                 = "Name"
    value               = "wordpress-instance"
    propagate_at_launch = true
  }

  tag {
    key                 = "Project"
    value               = "wordpress"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_policy" "wp_asg_scaleup_policy" {
  name                   = "wp-asg-scaleup"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = "${aws_autoscaling_group.wp_asg.name}"
}

resource "aws_autoscaling_policy" "wp_asg_scaledown_policy" {
  name                   = "wp-asg-scaledown"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = "${aws_autoscaling_group.wp_asg.name}"
}

resource "aws_cloudwatch_metric_alarm" "wp_cloudwatch_high_CPU_alarm" {
  alarm_name          = "wordpress-highest-cpu-usage-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Maximum"
  threshold           = "80"

  dimensions = {
    "AutoScalingGroupName" = "${aws_autoscaling_group.wp_asg.name}"
  }

  alarm_description = "Alarm-to-be-set-on-when-CPU>80%"
  alarm_actions     = ["${aws_autoscaling_policy.wp_asg_scaleup_policy.arn}"]
}

resource "aws_cloudwatch_metric_alarm" "wp_cloudwatch_low_CPU_alarm" {
  alarm_name          = "wordpress-lowest-cpu-usage-alarm"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Minimum"
  threshold           = "20"

  dimensions = {
    "AutoScalingGroupName" = "${aws_autoscaling_group.wp_asg.name}"
  }

  alarm_description = "Alarm-to-be-set-on-when-CPU<20%"
  alarm_actions     = ["${aws_autoscaling_policy.wp_asg_scaledown_policy.arn}"]
}
