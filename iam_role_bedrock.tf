# Knowladgebase role
resource "aws_iam_role" "rag-knowledge-base" {
  name               = "${local.service_name}-bedrock-execution-role-for-knowledge-base"
  assume_role_policy = <<JSON
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AmazonBedrockKnowledgeBaseTrustPolicy",
      "Effect": "Allow",
      "Principal": {
        "Service": "bedrock.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
JSON
}

resource "aws_iam_role_policy" "rag-knowledge-base" {
  name = "${local.service_name}-bedrock-exec-policy-for-knowledge-base"
  role = aws_iam_role.rag-knowledge-base.id

  policy = <<JSON
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "BedrockInvokeModelStatement",
      "Effect": "Allow",
      "Action": [
        "bedrock:InvokeModel"
      ],
      "Resource": [
        "*"
      ]
    },
    {
      "Sid": "OpenSearchServerlessAPIAccessAllStatement",
      "Effect": "Allow",
      "Action": [
        "aoss:APIAccessAll"
      ],
      "Resource": [
        "*"
      ]
    },
    {
      "Sid": "S3ListBucketStatement",
      "Effect": "Allow",
      "Action": [
        "s3:ListBucket"
      ],
      "Resource": [
        "*"
      ]
    },
    {
      "Sid": "S3GetObjectStatement",
      "Effect": "Allow",
      "Action": [
        "s3:GetObject"
      ],
      "Resource": [
        "*"
      ]
    }
  ]
}
JSON
}

# Agent role
resource "aws_iam_role" "rag-agents" {
  name               = "${local.service_name}-bedrock-execution-role-for-agents"
  assume_role_policy = <<JSON
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AmazonBedrockAgentBedrockFoundationModelPolicyProd",
      "Effect": "Allow",
      "Principal": {
        "Service": "bedrock.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
JSON
}

resource "aws_iam_role_policy" "rag-agents" {
  name = "${local.service_name}-bedrock-exec-policy-for-agents"
  role = aws_iam_role.rag-agents.id

  policy = <<JSON
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "BedrockInvokeModelStatement",
      "Effect": "Allow",
      "Action": [
        "bedrock:InvokeModel"
      ],
      "Resource": [
        "*"
      ]
    },
    {
      "Sid": "AmazonBedrockAgentRetrieveKnowledgeBasePolicyProd",
      "Effect": "Allow",
      "Action": [
        "bedrock:Retrieve"
      ],
      "Resource": [
        "*"
      ]
    }
  ]
}
JSON
}

resource "time_sleep" "aws_iam_role_policy_delay" {
  create_duration = "20s"
  depends_on = [
    aws_iam_role_policy.rag-knowledge-base,
    aws_iam_role_policy.rag-agents
  ]
}
