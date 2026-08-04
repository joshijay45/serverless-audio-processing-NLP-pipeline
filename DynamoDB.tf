resource "aws_dynamodb_table" "dynamodb_table_for_final_output" {
    name  = "${var.project_name}-final-output"
    billing_mode = "PAY_PER_REQUEST"
    hash_key = "JobId"
    attribute {
        name = "JobId"
        type = "S" 
    }
}