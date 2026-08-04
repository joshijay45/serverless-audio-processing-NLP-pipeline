# Bucket that receives raw .mp3 or .mp4 uploads 

resource "aws_s3_bucket" "input_bucket" {
    bucket = "${var.project_name}-input-bucket00"
    force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "input_bucket_public_access_block"{
    bucket = aws_s3_bucket.input_bucket.id
    block_public_acls = true
    block_public_policy = true 
    restrict_public_buckets = true
    ignore_public_acls = true
}

# Stores JSON transcripts from Amazon transcribe
resource "aws_s3_bucket" "transcribe_bucket" {
    bucket = "${var.project_name}-intermediate-bucket"
    force_destroy =  true
}

resource "aws_s3_bucket_public_access_block" "transcribe_bucket_public_access_block"{
    bucket = aws_s3_bucket.transcribe_bucket.id
    block_public_acls = true
    block_public_policy = true 
    restrict_public_buckets = true
    ignore_public_acls = true
}

# Stores translated final output
resource "aws_s3_bucket" "output_bucket" {
    bucket = "${var.project_name}-output-bucket"
    force_destroy =  true
}
resource "aws_s3_bucket_public_access_block" "output_bucket_public_access_block"{
    bucket = aws_s3_bucket.output_bucket.id
    block_public_acls = true
    block_public_policy = true 
    restrict_public_buckets = true
    ignore_public_acls = true
}

data "aws_iam_policy_document" "input_bucket_policy" {
    statement {
        sid = "AllowTranscribeRead"
        effect = "Allow"
        actions = ["s3:GetObject", "s3:ListBucket"]
        resources = [aws_s3_bucket.input_bucket.arn, "${aws_s3_bucket.input_bucket.arn}/*"]
        principals {
            type = "Service"
            identifiers = ["transcribe.amazonaws.com"]
        }
    }
}

resource "aws_s3_bucket_policy" "input_s3_bucket_policy"{
    bucket = aws_s3_bucket.input_bucket.id
    policy = data.aws_iam_policy_document.input_bucket_policy.json

}

data "aws_iam_policy_document" "transcribe_bucket_policy"{
    statement {
        sid = "AllowTranscribeWrite"
        effect = "Allow"
        actions = ["s3:PutObject"]
        resources = [aws_s3_bucket.transcribe_bucket.arn, "${aws_s3_bucket.transcribe_bucket.arn}/*"]
        principals {
            type = "Service"
            identifiers = ["transcribe.amazonaws.com"]
        }
    }
}

resource "aws_s3_bucket_policy" "transcribe_s3_bucket_policy" {
    bucket = aws_s3_bucket.transcribe_bucket.id
    policy = data.aws_iam_policy_document.transcribe_bucket_policy.json
}