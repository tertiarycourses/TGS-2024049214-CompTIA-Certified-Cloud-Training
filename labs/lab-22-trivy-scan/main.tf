resource "aws_s3_bucket" "bad" { bucket = "world-readable" }
resource "aws_s3_bucket_acl" "bad" { bucket = aws_s3_bucket.bad.id  acl = "public-read" }
