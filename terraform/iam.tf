resource "aws_iam_user" "jm" {
  name = "jmorgan"
}

resource "aws_iam_user_group_membership" "jmgroup" {
  user = "${aws_iam_user.jm.name}"

  groups = [
    "Admins",
  ]
}

resource "aws_iam_user_login_profile" "jmlogin" {
  user    = "${aws_iam_user.jm.name}"
  pgp_key = "keybase:terraform"
}
