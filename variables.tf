variable "project_id" {
  description = "flowing-access-433413-d5"
  type        = string
}

variable "region" {
  description = "The region for the resources"
  type        = string
  default     = "us-central1"
}

variable "vpc_name" {
  description = "Name of the VPC"
  type        = string
  default     = "three-tier-vpc"
}
