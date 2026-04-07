provider "google" {
  project = var.project_id
  region  = var.region
}

# ── APIs ──────────────────────────────────────────────────────────────────────

resource "google_project_service" "apis" {
  for_each = toset([
    "artifactregistry.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "iam.googleapis.com",
    "iamcredentials.googleapis.com",
    "run.googleapis.com",
    "secretmanager.googleapis.com",
    "serviceusage.googleapis.com",
    "storage.googleapis.com",
  ])

  project            = var.project_id
  service            = each.key
  disable_on_destroy = false
}

# ── Artifact Registry ─────────────────────────────────────────────────────────

resource "google_artifact_registry_repository" "smart_news" {
  project       = var.project_id
  location      = var.region
  repository_id = "smart-news"
  format        = "DOCKER"
  description   = "Docker images for smart-news"

  depends_on = [google_project_service.apis]
}

# ── Service accounts ──────────────────────────────────────────────────────────

resource "google_service_account" "deployer" {
  project      = var.project_id
  account_id   = "github-actions-deployer"
  display_name = "GitHub Actions Deployer"
}

resource "google_service_account" "cloud_run" {
  project      = var.project_id
  account_id   = "smart-news-runner"
  display_name = "Smart News Cloud Run"
}

# ── IAM — deployer roles ──────────────────────────────────────────────────────

resource "google_project_iam_member" "deployer_ar_writer" {
  project = var.project_id
  role    = "roles/artifactregistry.writer"
  member  = "serviceAccount:${google_service_account.deployer.email}"
}

resource "google_project_iam_member" "deployer_run_developer" {
  project = var.project_id
  role    = "roles/run.developer"
  member  = "serviceAccount:${google_service_account.deployer.email}"
}

resource "google_service_account_iam_member" "deployer_act_as_runner" {
  service_account_id = google_service_account.cloud_run.name
  role               = "roles/iam.serviceAccountUser"
  member             = "serviceAccount:${google_service_account.deployer.email}"
}

# ── IAM — Cloud Run SA secret access ─────────────────────────────────────────

resource "google_project_iam_member" "runner_secret_accessor" {
  project = var.project_id
  role    = "roles/secretmanager.secretAccessor"
  member  = "serviceAccount:${google_service_account.cloud_run.email}"
}

# Authoritative: only smart-news-runner may access Parameter Manager.
# This prevents any other SA (e.g. the default Compute SA) from holding this role.
resource "google_project_iam_binding" "runner_parameter_accessor" {
  project = var.project_id
  role    = "roles/parametermanager.parameterAccessor"
  members = ["serviceAccount:${google_service_account.cloud_run.email}"]
}

# ── Guard against roles/editor re-grant ──────────────────────────────────────
# GCP auto-grants roles/editor to the default Compute SA on project creation.
# This authoritative binding locks the role to zero members so any out-of-band
# grant causes `terraform plan` to flag drift.
resource "google_project_iam_binding" "no_editor" {
  project = var.project_id
  role    = "roles/editor"
  members = []
}

# ── Workload Identity Federation — deployer ───────────────────────────────────

resource "google_iam_workload_identity_pool" "github" {
  project                   = var.project_id
  workload_identity_pool_id = "github-pool"
  display_name              = "GitHub Actions Pool"
}

resource "google_iam_workload_identity_pool_provider" "github" {
  project                            = var.project_id
  workload_identity_pool_id          = google_iam_workload_identity_pool.github.workload_identity_pool_id
  workload_identity_pool_provider_id = "github-provider"
  display_name                       = "GitHub Provider"

  attribute_condition = "assertion.repository=='${var.github_repo}'"

  attribute_mapping = {
    "google.subject"       = "assertion.sub"
    "attribute.repository" = "assertion.repository"
    "attribute.ref"        = "assertion.ref"
    "attribute.actor"      = "assertion.actor"
  }

  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }
}

resource "google_service_account_iam_member" "deployer_wif" {
  service_account_id = google_service_account.deployer.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github.name}/attribute.repository/${var.github_repo}"
}

# ── Secret Manager ────────────────────────────────────────────────────────────

resource "google_secret_manager_secret" "gemini_api_key" {
  project   = var.project_id
  secret_id = "gemini-api-key"
  replication {
    auto {}
  }
  depends_on = [google_project_service.apis]
}

resource "google_secret_manager_secret" "sendgrid_api_key" {
  project   = var.project_id
  secret_id = "sendgrid-api-key"
  replication {
    auto {}
  }
  depends_on = [google_project_service.apis]
}

resource "google_secret_manager_secret" "sender_email" {
  project   = var.project_id
  secret_id = "sender-email"
  replication {
    auto {}
  }
  depends_on = [google_project_service.apis]
}

resource "google_secret_manager_secret" "recipient_email" {
  project   = var.project_id
  secret_id = "recipient-email"
  replication {
    auto {}
  }
  depends_on = [google_project_service.apis]
}

# ── Cloud Run ─────────────────────────────────────────────────────────────────

resource "google_cloud_run_v2_service" "smart_news" {
  project  = var.project_id
  name     = "smart-news"
  location = var.region

  deletion_protection = false

  template {
    service_account = google_service_account.cloud_run.email

    containers {
      # Placeholder image used only on initial creation.
      # CI/CD manages the deployed image; Terraform ignores subsequent image changes.
      image = "us-docker.pkg.dev/cloudrun/container/hello:latest"
      resources {
        limits = {
          cpu    = "1"
          memory = "512Mi"
        }
      }

      env {
        name  = "SPRING_PROFILES_ACTIVE"
        value = "gcp"
      }

      env {
        name = "GEMINI_API_KEY"
        value_source {
          secret_key_ref {
            secret  = google_secret_manager_secret.gemini_api_key.secret_id
            version = "latest"
          }
        }
      }

      env {
        name = "SENDGRID_API_KEY"
        value_source {
          secret_key_ref {
            secret  = google_secret_manager_secret.sendgrid_api_key.secret_id
            version = "latest"
          }
        }
      }

      env {
        name = "SENDGRID_FROM_EMAIL"
        value_source {
          secret_key_ref {
            secret  = google_secret_manager_secret.sender_email.secret_id
            version = "latest"
          }
        }
      }

      env {
        name = "SENDGRID_TO_EMAIL"
        value_source {
          secret_key_ref {
            secret  = google_secret_manager_secret.recipient_email.secret_id
            version = "latest"
          }
        }
      }
    }
  }

  depends_on = [
    google_project_service.apis,
    google_project_iam_member.runner_secret_accessor,
    google_project_iam_binding.runner_parameter_accessor,
  ]

  lifecycle {
    ignore_changes = [
      # CI/CD manages the image tag; prevent Terraform from reverting it.
      template[0].containers[0].image,
    ]
  }
}
