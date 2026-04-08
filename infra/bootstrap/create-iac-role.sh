#!/usr/bin/env bash
set -euo pipefail

# Bootstrap script: creates a custom IAM role and service account with the
# minimum permissions required for Terraform to manage smart-news infrastructure.
# Run this once manually before initialising Terraform.

PROJECT_ID="smart-news-20260321"
ROLE_ID="terraformIacAdmin"
ROLE_TITLE="Terraform IaC Admin"
ROLE_DESCRIPTION="Minimum permissions for the Terraform service account to manage smart-news infrastructure"
SA_NAME="terraform-iac"
SA_DISPLAY_NAME="Terraform IaC"

PERMISSIONS=(
  # Artifact Registry
  artifactregistry.repositories.create
  artifactregistry.repositories.delete
  artifactregistry.repositories.get
  artifactregistry.repositories.list
  artifactregistry.repositories.update

  # Cloud Run
  run.operations.get
  run.operations.list
  run.services.create
  run.services.delete
  run.services.get
  run.services.getIamPolicy
  run.services.list
  run.services.setIamPolicy
  run.services.update

  # Secret Manager
  secretmanager.secrets.create
  secretmanager.secrets.delete
  secretmanager.secrets.get
  secretmanager.secrets.getIamPolicy
  secretmanager.secrets.list
  secretmanager.secrets.setIamPolicy
  secretmanager.secrets.update
  secretmanager.versions.add
  secretmanager.versions.destroy
  secretmanager.versions.get
  secretmanager.versions.list

  # IAM — service accounts
  iam.serviceAccounts.actAs
  iam.serviceAccounts.create
  iam.serviceAccounts.delete
  iam.serviceAccounts.get
  iam.serviceAccounts.getIamPolicy
  iam.serviceAccounts.list
  iam.serviceAccounts.setIamPolicy
  iam.serviceAccounts.update

  # IAM — custom roles
  iam.roles.create
  iam.roles.delete
  iam.roles.get
  iam.roles.list
  iam.roles.undelete
  iam.roles.update

  # IAM — project-level bindings
  resourcemanager.projects.get
  resourcemanager.projects.getIamPolicy
  resourcemanager.projects.setIamPolicy

  # Workload Identity Federation
  iam.workloadIdentityPools.create
  iam.workloadIdentityPools.delete
  iam.workloadIdentityPools.get
  iam.workloadIdentityPools.list
  iam.workloadIdentityPools.undelete
  iam.workloadIdentityPools.update
  iam.workloadIdentityPoolProviders.create
  iam.workloadIdentityPoolProviders.delete
  iam.workloadIdentityPoolProviders.get
  iam.workloadIdentityPoolProviders.list
  iam.workloadIdentityPoolProviders.undelete
  iam.workloadIdentityPoolProviders.update

  # Cloud Storage — Terraform remote state bucket
  storage.buckets.create
  storage.buckets.delete
  storage.buckets.get
  storage.buckets.getIamPolicy
  storage.buckets.list
  storage.buckets.setIamPolicy
  storage.buckets.update
  storage.objects.create
  storage.objects.delete
  storage.objects.get
  storage.objects.list
  storage.objects.update

  # Service Usage — enabling GCP APIs
  serviceusage.services.enable
  serviceusage.services.get
  serviceusage.services.list
)

PERMISSIONS_CSV=$(IFS=,; echo "${PERMISSIONS[*]}")

echo "Creating custom IAM role '${ROLE_ID}' in project '${PROJECT_ID}'..."
gcloud iam roles create "${ROLE_ID}" \
  --project="${PROJECT_ID}" \
  --title="${ROLE_TITLE}" \
  --description="${ROLE_DESCRIPTION}" \
  --permissions="${PERMISSIONS_CSV}" \
  --stage="GA"

echo "Creating service account '${SA_NAME}'..."
gcloud iam service-accounts create "${SA_NAME}" \
  --project="${PROJECT_ID}" \
  --display-name="${SA_DISPLAY_NAME}"

SA_EMAIL="${SA_NAME}@${PROJECT_ID}.iam.gserviceaccount.com"

echo "Binding role to service account '${SA_EMAIL}'..."
gcloud projects add-iam-policy-binding "${PROJECT_ID}" \
  --member="serviceAccount:${SA_EMAIL}" \
  --role="projects/${PROJECT_ID}/roles/${ROLE_ID}"

echo ""
echo "Done."
echo "Service account: ${SA_EMAIL}"
