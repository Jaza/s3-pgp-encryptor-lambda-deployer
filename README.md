# s3-pgp-encryptor-lambda-deployer

Deploys [s3-pgp-encryptor-lib](https://github.com/Jaza/s3-pgp-encryptor-lib) to AWS
Lambda.

## Getting started

1. Fork, clone or download this project
1. Download latest Terraform (1.4.6 at time of writing) from
   https://www.terraform.io/downloads
1. Set `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, and `AWS_DEFAULT_REGION`
   environment variables per your AWS setup
1. Set the `TF_VAR_pgp_encrypt_bucket_region` and `TF_VAR_pgp_encrypt_bucket_name`
   environment variables
1. Set either `TF_VAR_pgp_public_key`, or `TF_VAR_secrets_manager_region` /
   `TF_VAR_secrets_manager_secret_id` / `TF_VAR_secrets_manager_secret_key`
1. Install and use nodejs 18.x (e.g. with `nvm use 18`)
1. `cd infra/modules/lambda/src`
1. `npm install`
1. `zip -r lambda_s3_pgp_encryptor.zip index.js node_modules`
1. In the `infra` top-level directory, create a file called `backend.tfvars` with:
   `bucket = "name-of-s3-bucket-for-your-tfstate"`
   `region = "your-aws-region"`
1. `cd infra`
1. `terraform init -backend-config=backend.tfvars`
1. `terraform workspace new fooenv`
1. Run `terraform plan` to preview what will be deployed
1. Run `terraform apply` to deploy everything
1. The Lambda function should work!

Built by [Seertech](https://www.seertechsolutions.com/).
