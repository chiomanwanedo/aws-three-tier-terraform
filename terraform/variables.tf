variable "acm_certificate_arn" {
  description = "ARN of the ACM certificate for HTTPS"
  type        = string
}


variable "db_password" {
  description = "Aurora master password"
  type        = string
  sensitive   = true
}

