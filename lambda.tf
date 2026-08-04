data "archive_file" "lambda_zip" {
    type = "zip"
    source_file = "${path.module}/src/transcribe.py"
    output_path = "${path.module}/src/transcribe.zip"
}

data "archive_file" "process_zip" {
    type = "zip"
    source_file = "${path.module}/src/process.py"
    output_path = "${path.module}/src/process.zip"
}

resource "aws_lambda_function" "transcribe_lambda" {
    filename = data.archive_file.lambda_zip.output_path
    function_name  = "${var.project_name}-transcribe-function"
    role = aws_iam_role.transcribe_role.arn
    handler = "transcribe.lambda_handler"
    runtime  = "python3.12"
    source_code_hash = data.archive_file.lambda_zip.output_base64sha256

    environment {
        variables = {
            TRANSCRIBE_BUCKET = aws_s3_bucket.transcribe_bucket.id
        }
    }
}

resource "aws_lambda_permission" "allow_input_bucket_trigger_lambda" {
    statement_id = "AllowS3InvokeTranscribe"
    action = "lambda:InvokeFunction"
    function_name = aws_lambda_function.transcribe_lambda.function_name
    principal = "s3.amazonaws.com"
    source_arn = aws_s3_bucket.input_bucket.arn
}

resource "aws_s3_bucket_notification" "input_bucket_notification" {
    bucket = aws_s3_bucket.input_bucket.id
    lambda_function {
        lambda_function_arn = aws_lambda_function.transcribe_lambda.arn
        events = ["s3:ObjectCreated:*"]
    }
    depends_on = [aws_lambda_permission.allow_input_bucket_trigger_lambda]
}

resource "aws_lambda_function" "processor_lambda" {
    filename = data.archive_file.process_zip.output_path
    function_name = "${var.project_name}-processor-lambda-function"
    role = aws_iam_role.processor_role.arn
    handler = "process.lambda_handler"
    runtime = "python3.12"
    source_code_hash = data.archive_file.process_zip.output_base64sha256

    environment {
        variables = {
            TARGET_LANGUAGE  = var.targeted_language
            OUTPUT_BUCKET    = aws_s3_bucket.output_bucket.id
            DYNAMODB_TABLE   = aws_dynamodb_table.dynamodb_table_for_final_output.name
        }
    }
}

resource "aws_lambda_permission" "allow_transcribe_bucket_trigger_lambda" {
    statement_id = "AllowS3InvokeAIProcessor"
    action = "lambda:InvokeFunction"
    function_name = aws_lambda_function.processor_lambda.function_name
    principal = "s3.amazonaws.com"
    source_arn = aws_s3_bucket.transcribe_bucket.arn
}

resource "aws_s3_bucket_notification" "transcribe_bucket_notification" {
    bucket = aws_s3_bucket.transcribe_bucket.id
    lambda_function {
        lambda_function_arn = aws_lambda_function.processor_lambda.arn
        events = ["s3:ObjectCreated:*"]
        filter_suffix = ".json"
    }

    depends_on = [aws_lambda_permission.allow_transcribe_bucket_trigger_lambda]
}