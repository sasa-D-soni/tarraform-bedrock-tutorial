#
# invoke bedrock from lambda
#
resource "aws_iam_role" "lambda-br" {

  name               = "${local.service_name}_lambda"
  assume_role_policy = <<JSON
{
  "Version": "2012-10-17",
  "Statement": [
    {
        "Action": "sts:AssumeRole",
        "Effect": "Allow",
        "Principal": {
            "Service": [
                "lambda.amazonaws.com"
            ]
        }
    }
  ]
}
JSON
}

resource "aws_iam_role_policy" "lambda-br" {
  name   = "lambda_additional"
  role   = aws_iam_role.lambda-br.id
  policy = <<JSON
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "bedrock:*"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
JSON
}
