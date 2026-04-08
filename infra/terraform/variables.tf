variable "project_id" {
  type        = string
  description = "GCP project ID; must be provided explicitly for the target environment"
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

variable "schedule" {
  type        = string
  description = "Initial cron schedule (UTC) for the news email job. After first apply, change this via Cloud Console — Terraform will not override it."
  default     = "0 7 * * 1"
}
