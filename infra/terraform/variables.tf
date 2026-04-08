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
