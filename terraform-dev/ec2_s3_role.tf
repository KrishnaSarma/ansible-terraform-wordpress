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
  policy      = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "s3:PutObject",
                "s3:GetObject",
                "s3:GetBucketLocation"
            ],
            "Resource": [
                "arn:aws:s3:::honeyenditsolutions-code-bucket*",
                "arn:aws:s3:::honeyenditsolutions-code-bucket/*"
            ]
        },
        {
            "Sid": "VisualEditor1",
            "Effect": "Allow",
            "Action": "s3:ListBucket",
            "Resource": "*"
        },
        {
            "Sid": "VisualEditor2",
            "Effect": "Allow",
            "Action": "s3:ListAllMyBuckets",
            "Resource": "*"
        }
    ]
}
EOF
  role = "${aws_iam_role.ec2_s3.id}"
}

resource "aws_iam_instance_profile" "role_instance_profile" {
  name = "iam_role_intance_profile"
  role = "${aws_iam_role.ec2_s3.name}"
}
