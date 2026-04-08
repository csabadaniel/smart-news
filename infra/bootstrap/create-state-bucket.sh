#!/usr/bin/env bash
set -euo pipefail

# Bootstrap script: creates the GCS bucket used for Terraform remote state.
# Run this once manually before initialising Terraform.

PROJECT_ID="smart-news-20260321"
BUCKET_NAME="${PROJECT_ID}-terraform-state"
REGION="us-central1"
SA_EMAIL="terraform-iac@${PROJECT_ID}.iam.gserviceaccount.com"

echo "Creating GCS bucket '${BUCKET_NAME}' in '${REGION}'..."
gcloud storage buckets create "gs://${BUCKET_NAME}" \
  --project="${PROJECT_ID}" \
  --location="${REGION}" \
  --uniform-bucket-level-access

echo "Enabling versioning on bucket '${BUCKET_NAME}'..."
gcloud storage buckets update "gs://${BUCKET_NAME}" \
  --versioning

echo "Granting terraform-iac SA read/write access to bucket..."
gcloud storage buckets add-iam-policy-binding "gs://${BUCKET_NAME}" \
  --member="serviceAccount:${SA_EMAIL}" \
  --role="roles/storage.objectAdmin"

echo ""
echo "Done."
echo "Bucket: gs://${BUCKET_NAME}"
