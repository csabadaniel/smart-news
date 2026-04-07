#!/usr/bin/env bash
set -euo pipefail

# Bootstrap script: creates a Workload Identity Federation pool and provider
# for the terraform-iac service account, allowing GitHub Actions to
# authenticate as terraform-iac without a long-lived key.
# Run this once manually before adding the Terraform CI job.

PROJECT_ID="smart-news-20260321"
PROJECT_NUMBER="425089232711"
POOL_ID="terraform-pool"
POOL_DISPLAY_NAME="Terraform Pool"
PROVIDER_ID="github-provider"
PROVIDER_DISPLAY_NAME="GitHub Provider"
GITHUB_REPO="csabadaniel/smart-news"
SA_EMAIL="terraform-iac@${PROJECT_ID}.iam.gserviceaccount.com"

echo "Creating Workload Identity Pool '${POOL_ID}'..."
gcloud iam workload-identity-pools create "${POOL_ID}" \
  --project="${PROJECT_ID}" \
  --location=global \
  --display-name="${POOL_DISPLAY_NAME}"

echo "Creating OIDC provider '${PROVIDER_ID}'..."
gcloud iam workload-identity-pools providers create-oidc "${PROVIDER_ID}" \
  --project="${PROJECT_ID}" \
  --location=global \
  --workload-identity-pool="${POOL_ID}" \
  --display-name="${PROVIDER_DISPLAY_NAME}" \
  --issuer-uri="https://token.actions.githubusercontent.com" \
  --attribute-mapping="google.subject=assertion.sub,attribute.repository=assertion.repository,attribute.ref=assertion.ref,attribute.actor=assertion.actor" \
  --attribute-condition="assertion.repository=='${GITHUB_REPO}'"

echo "Granting terraform-iac SA workload identity user binding..."
gcloud iam service-accounts add-iam-policy-binding "${SA_EMAIL}" \
  --project="${PROJECT_ID}" \
  --role="roles/iam.workloadIdentityUser" \
  --member="principalSet://iam.googleapis.com/projects/${PROJECT_NUMBER}/locations/global/workloadIdentityPools/${POOL_ID}/attribute.repository/${GITHUB_REPO}"

PROVIDER_RESOURCE="projects/${PROJECT_NUMBER}/locations/global/workloadIdentityPools/${POOL_ID}/providers/${PROVIDER_ID}"

echo ""
echo "Done."
echo "Workload Identity Provider resource name (use as GCP_TERRAFORM_WIF_PROVIDER secret):"
echo "  ${PROVIDER_RESOURCE}"
echo "Service account (use as GCP_TERRAFORM_SERVICE_ACCOUNT secret):"
echo "  ${SA_EMAIL}"
