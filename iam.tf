resource "aws_iam_role" "instance-role-for-ecs" {
  name = "instance-role-for-ecs"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "instance-profile-for-ecs" {
  name = "instance-profile-for-ecs"
  role = aws_iam_role.instance-role-for-ecs.name
}

resource "aws_iam_role_policy_attachment" "AmazonEC2RoleforSSM" {
  role = aws_iam_role.instance-role-for-ecs.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
}

resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerServiceforEC2Role" {
  role = aws_iam_role.instance-role-for-ecs.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_role_policy_attachment" "AmazonSNSFullAccess" {
  role = aws_iam_role.instance-role-for-ecs.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSNSFullAccess"
}

resource "aws_iam_role_policy_attachment" "AmazonElasticFileSystemFullAccess" {
  role = aws_iam_role.instance-role-for-ecs.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonElasticFileSystemFullAccess"
}

resource "aws_iam_role_policy_attachment" "AWSOpsWorksInstanceRegistration" {
  role = aws_iam_role.instance-role-for-ecs.name
  policy_arn = "arn:aws:iam::aws:policy/AWSOpsWorksInstanceRegistration"
}

resource "aws_iam_role_policy_attachment" "AWSOpsWorksCloudWatchLogs" {
  role = aws_iam_role.instance-role-for-ecs.name
  policy_arn = "arn:aws:iam::aws:policy/AWSOpsWorksCloudWatchLogs"
}

resource "aws_iam_role_policy_attachment" "instance-role-for-ecs-tagging-policy-attachment" {
  role       = aws_iam_role.instance-role-for-ecs.name
  policy_arn = "${aws_iam_policy.instance-role-for-ecs-tagging-policy.arn}"
}

resource "aws_iam_policy" "instance-role-for-ecs-tagging-policy" {
  name = "instance-role-for-ecs-tagging-policy"
  policy = "${file("templates/iam/instance-role-for-ecs-tagging-policy.json")}"
}
