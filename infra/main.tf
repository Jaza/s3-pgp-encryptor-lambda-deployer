terraform {
  required_version = ">= 1.4.6"

  backend "s3" {
    bucket = "${var.bucket}"
    key    = "s3-pgp-encryptor.tfstate"
    region = "${var.region}"
  }
}

locals {
  environment = "${terraform.workspace}"
  region      = "${data.aws_region.current.name}"
  account_id  = "${data.aws_caller_identity.current.account_id}"
}

provider "aws" {}

module "lambda" {
  source                     = "./modules/lambda"
  environment                = "${local.environment}"
  region                     = "${local.region}"
  account_id                 = "${local.account_id}"
  pgp_encrypt_bucket_region  = "${var.pgp_encrypt_bucket_region}"
  pgp_encrypt_bucket_name    = "${var.pgp_encrypt_bucket_name}"
  pgp_public_key             = "${var.pgp_public_key}"
  secrets_manager_region     = "${var.secrets_manager_region}"
  secrets_manager_secret_id  = "${var.secrets_manager_secret_id}"
  secrets_manager_secret_key = "${var.secrets_manager_secret_key}"
}
