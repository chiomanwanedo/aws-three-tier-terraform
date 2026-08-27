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


variable "slack_webhook_url" {
  description = "Slack webhook URL for incident notifications"
  type        = string
  sensitive   = true
}

variable "claude_api_key" {
  description = "Anthropic Claude API key"
  type        = string
  sensitive   = true
}
