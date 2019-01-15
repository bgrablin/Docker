# variable "access_key" { default = "RANDOMACCESS_KEY" }  # Credentials should be stored in ~/.aws/credentials on Linux, macOS, or Unix,  C:\Users\USERNAME\.aws\credentials on Windows
# variable "secret_key" { default = "RANDOMACCESS_KEY" }

# Credentials fils should be in the following format
# [default]
# aws_access_key_id = your_access_key_id
# aws_secret_access_key = your_secret_access_key

variable "region" { default = "us-west-2" }
variable "default_AZ" { default = "us-west-2a" }
variable cidr_block_internet { default = "0.0.0.0/0" }
variable "ssh_key_public" {
  default     = "~/.ssh/id_rsa.pub"
  description = "Path to the SSH public key for accessing cloud instances. Used for creating AWS keypair."
}
variable "ssh_key_private" {
  default     = "~/.ssh/id_rsa"
  description = "Path to the SSH private key for accessing cloud instances."
}
variable "ips" {
    default = {
        "0" = "172.31.31.195",
        "1" = "172.31.31.196",
    }
}