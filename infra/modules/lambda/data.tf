data "aws_s3_bucket" "s3_pgp_encryptor_s3_bucket" {
  bucket = "${var.pgp_encrypt_bucket_name}"
}
