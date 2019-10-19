variable "region" {
  type    = string
  default = "eu-west-2"
}

variable "public_key" {
  type        = string
  description = "File path of public key."
  default     = "~/.ssh/id_rsa.pub"
}

variable "private_key" {
  type        = string
  description = "File path of private key."
  default     = "~/.ssh/id_rsa"
}

variable "domain" {
  type        = string
  description = "Name of domain."
}
