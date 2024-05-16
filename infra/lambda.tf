variable "lambda_function_name" {
  default = "kanye-rest"
}
variable "lambda_layer_name" {
  default = "requests-layer"
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

data "archive_file" "kanye_rest_src" {
  type        = "zip"
  source_file  = "${dirname(abspath(path.root))}/data-pipelines/${var.lambda_function_name}/lambda_function.py"
  output_path = "${dirname(abspath(path.root))}/data-pipelines/${var.lambda_function_name}.zip"
}

data "archive_file" "kanye_rest_layer" {
  type        = "zip"
  source_dir  = "${dirname(abspath(path.root))}/kanye-rest-layer"
  output_path = "${dirname(abspath(path.root))}/${var.lambda_layer_name}.zip"
}
resource "aws_lambda_layer_version" "kanye_rest_layer" {
  filename   = data.archive_file.kanye_rest_layer.output_path
  layer_name = var.lambda_layer_name
  compatible_runtimes = ["python3.12"]
}

resource "aws_iam_role" "iam_for_lambda" {
  name               = "iam_for_lambda"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}


# This is to optionally manage the CloudWatch Log Group for the Lambda Function.
# If skipping this resource configuration, also add "logs:CreateLogGroup" to the IAM policy below.
resource "aws_cloudwatch_log_group" "lambda_log_group" {
  name              = "/aws/lambda/${var.lambda_function_name}"
  retention_in_days = 14
}

# See also the following AWS managed policy: AWSLambdaBasicExecutionRole
data "aws_iam_policy_document" "lambda_logging" {
  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = ["arn:aws:logs:*:*:*"]
  }
}

resource "aws_iam_policy" "lambda_logging" {
  name        = "lambda_logging"
  path        = "/"
  description = "IAM policy for logging from a lambda"
  policy      = data.aws_iam_policy_document.lambda_logging.json
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.lambda_logging.arn
}


resource "aws_lambda_function" "kanye_rest_lambda" {
  function_name = var.lambda_function_name
  role = aws_iam_role.iam_for_lambda.arn
  filename = data.archive_file.kanye_rest_src.output_path
  runtime = "python3.12"
  handler = "lambda_function.lambda_handler"
  layers = [aws_lambda_layer_version.kanye_rest_layer.arn]
  vpc_config {
    security_group_ids = []
    subnet_ids = [aws_subnet.private_subnet.id]
  }

  # Advanced logging controls (optional)
  logging_config {
    log_format = "JSON"
    log_group = aws_cloudwatch_log_group.lambda_log_group.name
    application_log_level = "INFO"
    system_log_level = "INFO"
  }

  depends_on = [
    aws_iam_role_policy_attachment.lambda_logs,
    aws_cloudwatch_log_group.lambda_log_group,
    aws_vpc.main
  ]
}


resource "aws_lambda_function_url" "kanye_rest_url" {
  function_name      = aws_lambda_function.kanye_rest_lambda.function_name
  authorization_type = "NONE"
}
