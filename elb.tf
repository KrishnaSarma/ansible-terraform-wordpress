resource "aws_lb" "wordpress_network_loadbalancer" {
  name               = "wordpress-loadbalancer"
  internal           = false
  load_balancer_type = "network"
  subnets            = ["${aws_subnet.subnet_availability_zone_a.id}", "${aws_subnet.subnet_availability_zone_b.id}", "${aws_subnet.subnet_availability_zone_c.id}"]

  tags {
    Name = "wordpress_loadbalancer"
  }

  enable_deletion_protection = true
}

resource "aws_lb_target_group" "wordpress_instance_target" {
  name     = "wordpress-lb-instance-tg"
  port     = "80"
  protocol = "TCP"
  vpc_id   = "${aws_vpc.wordpress_vpc.id}"
}

resource "aws_lb_listener" "wordpress_http_lb_listener" {
  load_balancer_arn = "${aws_lb.wordpress_network_loadbalancer.arn}"
  port              = "80"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.wordpress_instance_target.arn}"
  }
}

resource "aws_lb_listener" "wordpress_https_lb_listener" {
  load_balancer_arn = "${aws_lb.wordpress_network_loadbalancer.arn}"
  port              = "443"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.wordpress_instance_target.arn}"
  }
}

#changes when ASG is implemented

resource "aws_lb_target_group_attachment" "wordpress_target_group_attachment" {
  target_group_arn = "${aws_lb_target_group.wordpress_instance_target.arn}"
  target_id        = "${aws_instance.ec2_instance.id}"
  port             = "80"
}
