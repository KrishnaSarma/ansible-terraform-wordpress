data "aws_iam_policy_document" "s3_read_write" {

  statement {

  actions = [
      "s3:ListAllMyBuckets",
      "s3:GetBucketLocation",
    ]

    resources = [
      "arn:aws:s3:::*",
    ]
  }

  statement {

  actions = [
    "s3:ListBucket",
  ]

  resources = [
    "arn:aws:s3:::honeyenditsolutions-code-bucket"]
  }

  statement {

  actions = [
    "s3:GetObject",
    "s3:PutObject"
  ]

  resources = [
    "arn:aws:s3:::honeyenditsolutions-code-bucket"]
  }
}

data "aws_iam_policy_document" "assume_role" {
        statement {

                effect  = "Allow"
                actions = [
                        "sts:AssumeRole",
                ]

                principals = {
                        type = "Service"
                        identifiers = [ "ec2.amazonaws.com" ]
               }
        }
}


resource "aws_iam_role" "ec2_s3" {
  name = "ec2_s3_access_role"
  assume_role_policy = "${data.aws_iam_policy_document.assume_role.json}"
}

resource "aws_iam_role_policy" "ec2_s3_readwrite" {
  name        = "WP_EC2_S3_read_write_policy"
  policy      = "${data.aws_iam_policy_document.s3_read_write.json}"
  role = "${aws_iam_role.ec2_s3.id}"
}

resource "aws_iam_instance_profile" "role_instance_profile" {
  name = "iam_role_intance_profile"
  role = "${aws_iam_role.ec2_s3.name}"
}
