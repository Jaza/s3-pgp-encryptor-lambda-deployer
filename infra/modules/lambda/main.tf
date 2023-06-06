resource "aws_iam_role" "s3_pgp_encryptor_lambda_role" {
  name = "${var.environment}_s3_pgp_encryptor_iam_for_lambda"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Sid    = ""
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "s3_pgp_encryptor_lambda_policy" {
  role       = aws_iam_role.s3_pgp_encryptor_lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_policy" "s3_pgp_encryptor_lambda_s3_policy" {
  name = "${var.environment}_s3_pgp_encryptor_lambda_s3_policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "s3:GetObject",
        "s3:PutObject",
        "s3:DeleteObject"
      ]
      Resource = [
        "arn:aws:s3:::${var.pgp_encrypt_bucket_name}",
        "arn:aws:s3:::${var.pgp_encrypt_bucket_name}/*"
      ]
    }]
  })
}

resource "aws_iam_role_policy_attachment" "s3_pgp_encryptor_lambda_s3_policy_attachment" {
  role       = "${aws_iam_role.s3_pgp_encryptor_lambda_role.name}"
  policy_arn = "${aws_iam_policy.s3_pgp_encryptor_lambda_s3_policy.arn}"
}

resource "aws_iam_policy" "s3_pgp_encryptor_lambda_secrets_manager_policy" {
  count = "${var.secrets_manager_secret_id}" != "" ? 1 : 0
  name  = "${var.environment}_s3_pgp_encryptor_lambda_secrets_manager_policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "secretsmanager:GetSecretValue"
      ]
      Resource = [
        "${var.secrets_manager_secret_id}"
      ]
    }]
  })
}

resource "aws_iam_role_policy_attachment" "s3_pgp_encryptor_lambda_secrets_manager_policy_attachment" {
  count      = "${var.secrets_manager_secret_id}" != "" ? 1 : 0
  role       = "${aws_iam_role.s3_pgp_encryptor_lambda_role.name}"
  policy_arn = "${aws_iam_policy.s3_pgp_encryptor_lambda_secrets_manager_policy[0].arn}"
}

resource "aws_lambda_function" "s3_pgp_encryptor_lambda" {
  filename          = "modules/lambda/src/lambda_s3_pgp_encryptor.zip"
  function_name     = "${var.environment}_s3_pgp_encryptor_lambda"
  role              = "${aws_iam_role.s3_pgp_encryptor_lambda_role.arn}"
  handler           = "index.handler"
  source_code_hash  = "${filebase64sha256("modules/lambda/src/lambda_s3_pgp_encryptor.zip")}"
  runtime           = "nodejs18.x"
  timeout           = 30
  memory_size       = 4096

  environment {
    variables = {
      PGP_PUBLIC_KEY             = "${var.pgp_public_key}"
      SECRETS_MANAGER_REGION     = "${var.secrets_manager_region}"
      SECRETS_MANAGER_SECRET_ID  = "${var.secrets_manager_secret_id}"
      SECRETS_MANAGER_SECRET_KEY = "${var.secrets_manager_secret_key}"
    }
  }
}

resource "aws_cloudwatch_log_group" "s3_pgp_encryptor_lambda_log_group" {
  name = "/aws/lambda/${aws_lambda_function.s3_pgp_encryptor_lambda.function_name}"

  retention_in_days = 30
}

resource "aws_lambda_permission" "s3_pgp_encryptor_lambda_permission" {
    statement_id  = "AllowS3Invoke"
    action        = "lambda:InvokeFunction"
    function_name = "${aws_lambda_function.s3_pgp_encryptor_lambda.function_name}"
    principal     = "s3.amazonaws.com"
    source_arn    = "arn:aws:s3:::${var.pgp_encrypt_bucket_name}"
}

resource "aws_s3_bucket_notification" "s3_pgp_encryptor_s3_lambda_trigger" {
  bucket = "${data.aws_s3_bucket.s3_pgp_encryptor_s3_bucket.id}"

  lambda_function {
    lambda_function_arn = "${aws_lambda_function.s3_pgp_encryptor_lambda.arn}"
    events              = ["s3:ObjectCreated:*"]
    filter_suffix       = ".csv"
  }
}
