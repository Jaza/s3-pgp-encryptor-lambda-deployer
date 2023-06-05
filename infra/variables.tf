variable "pgp_encrypt_bucket_region" {}
variable "pgp_encrypt_bucket_name" {}

variable "pgp_public_key" {
  type    = string
  default = ""
}

variable "secrets_manager_region" {
  type    = string
  default = ""
}

variable "secrets_manager_secret_id" {
  type    = string
  default = ""
}

variable "secrets_manager_secret_key" {
  type    = string
  default = ""
}
