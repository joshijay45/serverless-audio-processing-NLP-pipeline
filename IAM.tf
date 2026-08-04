data "aws_iam_policy_document" "lambda_trust_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
        type =  "Service"
        identifiers = ["lambda.amazonaws.com"]
    }
  }

}

# IAM role for transcribe 

resource "aws_iam_role" "transcribe_role" {
    name = "${var.project_name}-transcribe-role"
    assume_role_policy = data.aws_iam_policy_document.lambda_trust_policy.json
}

# Basic cloudwatch logging permissions 

resource "aws_iam_role_policy_attachment" "lambda_transcribe_role_policy" {
    role = aws_iam_role.transcribe_role.name
    policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Policy allowing lambda to read from s3 and trigger transcirbe 

data "aws_iam_policy_document" "lambda_s3_transcribe_policy" {
    statement {
       sid = "AllowS3Read"
       effect = "Allow"
       actions = ["s3:GetObject"]
       resources = ["${aws_s3_bucket.input_bucket.arn}/*"]
    }
    statement {
    sid = "AllowWriteIntermediate"
    effect = "Allow"
    actions = ["s3:PutObject", "s3:GetBucketLocation"]
    resources = [
        aws_s3_bucket.transcribe_bucket.arn,
        "${aws_s3_bucket.transcribe_bucket.arn}/*"
    ]
}
    statement {
        sid = "AllowTranscribeStart"
        effect = "Allow"
        actions = ["transcribe:StartTranscriptionJob"]
        resources = ["*"]
    }
}

resource "aws_iam_policy" "transcribe_policy" {
    name = "${var.project_name}-transcribe-policy"
    policy = data.aws_iam_policy_document.lambda_s3_transcribe_policy.json

}

resource "aws_iam_role_policy_attachment" "transcribe_policy_attach" {
    role = aws_iam_role.transcribe_role.name
    policy_arn = aws_iam_policy.transcribe_policy.arn
}

data "aws_iam_policy_document" "allow_transcirbe_write_to_s3" {
    statement {
        sid = "AllowTranscribeToPutObject"
        effect = "Allow"
        actions = ["s3:PutObject"]
        resources = ["${aws_s3_bucket.transcribe_bucket.arn}/*"]
        principals {
            type = "Service"
            identifiers = ["transcribe.amazonaws.com"]
        }
    }
}

resource "aws_s3_bucket_policy" "transcribe_bucket_policy" {
    bucket = aws_s3_bucket.transcribe_bucket.id
    policy = data.aws_iam_policy_document.allow_transcirbe_write_to_s3.json
}

resource "aws_iam_role" "processor_role" {
    name = "${var.project_name}-processor-role"
    assume_role_policy = data.aws_iam_policy_document.lambda_trust_policy.json
}

data "aws_iam_policy_document" "processor_policy" {
    statement {
        sid = "AllowReadTranscript"
        effect = "Allow"
        actions = ["s3:GetObject"]
        resources = ["${aws_s3_bucket.transcribe_bucket.arn}/*"]
    }
    statement  {
        sid = "AllowWriteFinaloutput"
        effect = "Allow"
        actions = ["s3:PutObject"]
        resources = ["${aws_s3_bucket.output_bucket.arn}/*"]
    }
    statement {
        sid = "AllowDynamoDBWrite"
        effect = "Allow"
        actions = ["dynamodb:PutItem"]
        resources = ["${aws_dynamodb_table.dynamodb_table_for_final_output.arn}"]
    }
    statement {
        sid = "AllowMLServices"
        effect = "Allow"
        actions = ["translate:TranslateText","comprehend:DetectSentiment"]
        resources = ["*"]
    }
}

resource "aws_iam_role_policy_attachment" "processor_logs" {
    role = aws_iam_role.processor_role.name
    policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_policy" "processor_policy_1" {
    name = "${var.project_name}-processor-policy-1"
    policy = data.aws_iam_policy_document.processor_policy.json
}

resource "aws_iam_role_policy_attachment" "processor_policy_attach" {
    role = aws_iam_role.processor_role.name
    policy_arn = aws_iam_policy.processor_policy_1.arn
}
