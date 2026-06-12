variable "acm_certificate_arn" {
  description = "ARN of the ACM certificate for HTTPS"
  type        = string
}


variable "db_password" {
  description = "Aurora master password"
  type        = string
  sensitive   = true
}


variable "db_username" {
  description = "Database username"
  type        = string
}


variable "db_name" {
  description = "Database name"
  type        = string
}
