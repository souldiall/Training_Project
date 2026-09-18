resource "aws_s3_bucket" "remote_states" {
  bucket        = "my-bucket-soul2026"
  force_destroy = true
  tags = {
    Name      = "regular storage"
    Env       = "dep"
    ManagedBy = "Terraform"
  }
}

resource "aws_s3_bucket_versioning" "remote_state_versioning" {
  bucket = aws_s3_bucket.remote_states.id
  versioning_configuration {
    status = "Enabled"
  }
}