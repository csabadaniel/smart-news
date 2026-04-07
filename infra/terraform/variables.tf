variable "project_id" {
  type        = string
  description = "GCP project ID"
  default     = "smart-news-20260321"
}

variable "project_number" {
  type        = string
  description = "GCP project number"
  default     = "425089232711"
}

variable "region" {
  type        = string
  description = "GCP region for all regional resources"
  default     = "us-central1"
}

variable "github_repo" {
  type        = string
  description = "GitHub repository in owner/repo format"
  default     = "csabadaniel/smart-news"
}

variable "gemini_api_key" {
  type        = string
  description = "Gemini API key"
  sensitive   = true
}

variable "sendgrid_api_key" {
  type        = string
  description = "SendGrid API key"
  sensitive   = true
}

variable "sender_email" {
  type        = string
  description = "Email address used as the mail sender"
}

variable "recipient_email" {
  type        = string
  description = "Email address the news digest is delivered to"
}
