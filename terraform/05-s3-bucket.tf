resource "aws_s3_bucket" "web_s3_bucket" {
  bucket = "${var.environment}-${var.cluster_name}"

  tags = {
    Name        = "${var.environment}-${var.cluster_name}"
    Environment = var.environment
  }
}
