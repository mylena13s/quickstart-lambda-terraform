provider "aws" {
  region = "us-east-1" 
}


data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "iam_for_lambda" {
  name               = "iam_for_lambda"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

data "archive_file" "lambda" {
  type        = "zip"
  source_file = "${path.module}/../lambda/lambda_handler.py"
  output_path = "${path.module}/lambda_function_lambda.zip"
}

resource "aws_lambda_function" "lambda" {
  function_name    = "python_terraform_lambda"
  role             = aws_iam_role.iam_for_lambda.arn
  filename         = "${path.module}/lambda_function_lambda.zip"
  source_code_hash = data.archive_file.lambda.output_base64sha256

  runtime = "python3.10"
  handler = "lambda_handler.lambda_handler"
}
