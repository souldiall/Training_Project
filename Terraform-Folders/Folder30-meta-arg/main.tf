# This file is to create two resources on different AWS rgions
resource "aws_s3_bucket" "bucket-east" {
  bucket = "soul-bucket-east"
  tags = {
    Name = "My-east-bucket"
  }
  lifecycle {
    prevent_destroy = false
  }
}


resource "aws_iam_policy" "soul_policy" {
  provider = aws.west


  name = "soulMetaPolicy"
  depends_on = [
    aws_s3_bucket.bucket-east
  ]
  description = "Policy created to practice Terraform meta-arguments"

  # TODO: Assign the west provider alias
  # TODO: Add depends_on so this policy waits for the S3 bucket

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = ["s3:ListBucket"]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}
resource "aws_dynamodb_table" "db-table" {
  depends_on = [aws_iam_policy.soul_policy]
  provider   = aws.west
  lifecycle {
    create_before_destroy = true
    ignore_changes        = [read_capacity]
  }
  name         = "meta-argument-table"
  billing_mode = "PROVISIONED"

  # TODO: Add create_before_destroy lifecycle rule
  # TODO: Add ignore_changes for read_capacity

  read_capacity  = 5
  write_capacity = 5

  hash_key = "id"

  attribute {
    name = "id"
    type = "S"
  }
}
