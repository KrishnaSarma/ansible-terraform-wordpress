data "aws_instances" "instance_id" {
  instance_tags = {
    Project = "wordpress"
  }

  instance_state_names = ["running", "stopped"]
}

resource "null_resource" "get_ip_address" {
  count = "${length(data.aws_instances.instance_id.public_ips)}"

  triggers = {
    instance_count = "${length(data.aws_instances.instance_id.public_ips)}"
  }

  provisioner "local-exec" {
    command = "echo ${data.aws_instances.instance_id.public_ips[count.index]} >> hosts"
  }

  provisioner "local-exec" {
    command = "mv hosts ../ansible_code/"
  }
}
