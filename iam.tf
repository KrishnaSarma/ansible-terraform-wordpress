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

output "password" {
  value = "${aws_iam_user_login_profile.jmlogin.encrypted_password}"
}

output "encryption_key" {
  value = "${aws_iam_user_login_profile.jmlogin.key_fingerprint}"
}
