# IAM policy used for the EC2s from the ASG that
# enables them to access the DynamoDB and S3

resource "aws_iam_policy" "dynamodb_policy" {
  name = "dynamodb_s3_policy"
 policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "dynamodb:GetItem",
        "dynamodb:PutItem",
        "dynamodb:UpdateItem",
        "dynamodb:DeleteItem",
        "dynamodb:Query",
        "dynamodb:Scan"
      ],
      "Resource": "arn:aws:dynamodb:${var.region}:${data.aws_caller_identity.account_info.account_id }:table/${var.app_name}-table"
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:PutObject",
        "s3:GetObject",
        "s3:DeleteObject"
      ],
      "Resource": "arn:aws:s3:::${var.app_name}/*"
    }
  ]
}
EOF
}


# IAM service role for the EC2s from the launch template used in the ASG

resource "aws_iam_role" "app_asg_service_role" {
  name = "app_asg_service_role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

# Policy is attached to the service role

resource "aws_iam_role_policy_attachment" "role_policy" {
  role = aws_iam_role.app_asg_service_role.name
  policy_arn = aws_iam_policy.dynamodb_policy.arn
}

# Since this is used for an EC2 instance, we need to use an instance profile
# NOTE: The resource is called "app_lt_profile" because the role is
# assigned to the EC2s launched BY the launch template

resource "aws_iam_instance_profile" "app_lt_profile" {
  name = "${var.app_name}-lt"
  role = aws_iam_role.app_asg_service_role.name
}

