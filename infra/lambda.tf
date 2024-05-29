variable "lambda_function_name" {
  default = "kanye-rest"
}
variable "lambda_layer_name" {
  default = "requests-layer"
}
variable "lambda_python_version" {
  default = "python3.9"
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
  source_dir  = "${dirname(abspath(path.root))}/${var.lambda_layer_name}"
  output_path = "${dirname(abspath(path.root))}/${var.lambda_layer_name}.zip"
}
resource "aws_lambda_layer_version" "kanye_rest_layer" {
  filename   = data.archive_file.kanye_rest_layer.output_path
  layer_name = var.lambda_layer_name
  compatible_runtimes = [var.lambda_python_version]
}

resource "aws_iam_role" "iam_for_lambda" {
  name               = "iam_for_lambda"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
  tags = var.tags
}


# This is to optionally manage the CloudWatch Log Group for the Lambda Function.
# If skipping this resource configuration, also add "logs:CreateLogGroup" to the IAM policy below.
resource "aws_cloudwatch_log_group" "lambda_log_group" {
  name              = "/aws/lambda/${var.lambda_function_name}"
  retention_in_days = 14
  tags = var.tags
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
  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.lambda_logging.arn
}
resource "aws_iam_role_policy_attachment" "AWSLambdaVPCAccessExecutionRole" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}


resource "aws_lambda_function" "kanye_rest_lambda" {
  function_name = var.lambda_function_name
  role = aws_iam_role.iam_for_lambda.arn
  filename = data.archive_file.kanye_rest_src.output_path
  runtime = var.lambda_python_version
  handler = "lambda_function.lambda_handler"
  layers = [aws_lambda_layer_version.kanye_rest_layer.arn]
  vpc_config {
    security_group_ids = [aws_security_group.lambda_sg.id]
    subnet_ids = [aws_subnet.private_subnet[0].id]
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

  tags = var.tags
}
