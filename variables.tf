variable "aws_profile" {
  description = "AWS profile to use while deploying."
  type        = string
}

variable "region" {
  description = "AWS region to deploy to."
  type        = string
  default     = "eu-west-2"
}

variable "environment" {
  description = "Environment name where deployment is being applied."
  type        = string
}

variable "terraform_state_name" { 
  description = "The name of the terraform state "
  type        = string
}

variable "force_destroy" {
  description = "Force destroy, if true, will create resource so they can be destroyed."
  type        = bool
  default     = false
}