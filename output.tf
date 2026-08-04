output "input_bucket_name" {
  description = "Upload .mp3 file here"
  value =  aws_s3_bucket.input_bucket.id
}

output "output_bucket_name" {
  description = "Translated file will appear here"
  value = aws_dynamodb_table.dynamodb_table_for_final_output.name
}