data "archive_file" "lambda" {
  type        = "zip"
  source_file = "scripts/lambda_invoke_agent.py"
  output_path = "payload/lambda_function_payload.zip"
}

resource "aws_lambda_function" "invoke_agent" {
  # If the file is not in the current working directory you will need to include a
  # path.module in the filename.
  filename      = "payload/lambda_function_payload.zip"
  function_name = "${local.service_name}_invoke_agent"
  role          = aws_iam_role.lambda-br.arn
  handler       = "lambda_invoke_agent.lambda_handler"
  timeout       = 60

  source_code_hash = data.archive_file.lambda.output_base64sha256

  runtime = "python3.12"
  
}
