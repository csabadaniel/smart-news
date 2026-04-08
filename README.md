# smart-news

## Project Goal

Build a reliable scheduled service that prompts Gemini and sends the generated result by email, with a setup that is simple to operate, secure, and cost-aware for Google Cloud free-tier-friendly deployment.

## Tech Stack

- Java 21 LTS (initial baseline), with planned upgrade validation for Java 25 LTS
- Spring Boot 4.0.3 (must support Java 21 baseline and planned validation on Java 25 LTS)
- Spring AI
- Maven
- Lombok
- Gemini API (Google AI)
- SendGrid (email delivery)
- Docker
- GitHub Actions
- Terraform
- Google Cloud: Cloud Run (container runtime), Artifact Registry, Secret Manager, Parameter Manager

## Constraints

- Must stay free-tier-friendly on Google Cloud for low-volume usage.
- Must run reliably on schedule even when the service scales to zero.
- Must keep secrets out of source control and use managed secret storage.
- Must provide traceable CI/CD from GitHub to container deployment.
- Must keep the architecture simple enough for iterative learning and delivery.

## Iteration Process

- Each iteration is delivered through one pull request.
- Create a branch per iteration using `iteration/<number>-<topic>` naming.
- Keep each iteration small and focused on one goal.
- Do not push directly to main.
- Require CI to pass before merge.
- Prefer squash merge to keep history clean and readable.

## Iterations

| #   | Goal                                                      | Branch                                      | Status      |
| --- | --------------------------------------------------------- | ------------------------------------------- | ----------- |
| 01  | Document project intent and workflow                      | iteration/01-project-intent                 | Completed   |
| 02  | Build the base service responding to an external API call | iteration/02-base-service-external-api      | Completed   |
| 03  | Deploy the base service to GCP Cloud Run                  | iteration/03-deploy-to-gcp                  | Completed   |
| 04  | Integrate with Gemini API for content generation          | iteration/04-gemini-integration             | Completed   |
| 05  | Integrate email sending                                   | iteration/05-email-integration              | Completed   |
| 06  | Optimize CI workflow to reduce redundancy                 | iteration/06-optimize-ci-workflow           | Completed   |
| 07  | Implement Infrastructure as Code (IaC)                    | iteration/07-iac                            | Completed   |
| 08  | Fix Cloud Run Artifact Registry pull permissions          | iteration/08-fix-cloud-run-ar-reader        | Completed   |
| 09  | Fix Terraform Cloud Run drift from gcloud metadata        | iteration/09-fix-terraform-cloud-run-drift  | Completed   |

## Deploy to GCP Cloud Run

Infrastructure is managed with Terraform (`infra/terraform/`). Bootstrap scripts in `infra/bootstrap/` must be run once manually before the first `terraform apply`.

### Bootstrap (one-time)

1. Run `infra/bootstrap/create-iac-role.sh` — creates the `terraform-iac` service account and custom IAM role.
2. Run `infra/bootstrap/create-state-bucket.sh` — creates the GCS remote state bucket in `us-central1`.
3. Run `infra/bootstrap/create-wif-terraform.sh` — creates the Workload Identity Federation pool/provider for the Terraform SA.
4. Add GitHub Actions secrets (Settings → Secrets and variables → Actions):
   - `GCP_TERRAFORM_WIF_PROVIDER` — printed by `create-wif-terraform.sh`
   - `GCP_TERRAFORM_SERVICE_ACCOUNT` — `terraform-iac@smart-news-20260321.iam.gserviceaccount.com`

### Terraform-managed resources

All of the following are created and managed by `terraform apply`:

- GCP APIs
- Artifact Registry repository (`us-central1`)
- Service accounts: `github-actions-deployer`, `smart-news-runner`
- IAM bindings for both service accounts
- Workload Identity Federation pool/provider for `github-actions-deployer`
- Secret Manager secrets (values must be set manually after `terraform apply`):
  - `gemini-api-key`
  - `sendgrid-api-key`
  - `sender-email`
  - `recipient-email`
- Cloud Run service (`us-central1`)

### GitHub Actions secrets (managed separately)

- `GCP_PROJECT_ID`
- `GCP_WORKLOAD_IDENTITY_PROVIDER` — output by Terraform (`wif_provider`)
- `GCP_SERVICE_ACCOUNT` — output by Terraform (`deployer_service_account`)
- `GCP_TERRAFORM_WIF_PROVIDER`
- `GCP_TERRAFORM_SERVICE_ACCOUNT`

### GCP Parameter Manager parameters (global, set manually)

- `smart-news-model` (latest): the Gemini model name (e.g. `gemini-2.5-flash`)
- `smart-news-prompt` (latest): the prompt sent to Gemini on each `/news` request

### Non-obvious behavior

- Build runs on every `push` and manual `workflow_dispatch`. On feature branches, only the Maven build and tests run; the Docker build and smoke test are skipped to keep feedback fast.
- On pushes to `main` and manual `workflow_dispatch` runs, the build job also builds and smoke-tests the Docker image, then saves it as a workflow artifact.
- Deployment runs only on manual `workflow_dispatch` requests and pushes to `main`.
- Deployment does not require a separate approval step.
- The Docker image built and tested in the build job is saved as a workflow artifact and loaded by the deploy job. It is never rebuilt during deploy.
- The `gcp` Spring profile is activated on Cloud Run; it enables GCP Parameter Manager to supply the model name and prompt at runtime.
- Secrets are resolved at startup via `sm://` property placeholders using fully-qualified resource names (e.g. `sm://projects/smart-news-20260321/secrets/gemini-api-key`). Fully-qualified names are used to avoid a known Spring Cloud GCP bootstrap-phase bug where short secret names can silently fail to resolve if the project ID provider is not yet initialised.
- Prompt, model, sender address, and recipient address can be updated without redeployment by creating a new parameter or secret version and calling `POST /actuator/refresh`. `NewsService` is annotated with `@RefreshScope`, so it picks up the new values on the next request. The refresh endpoint is only exposed under the `gcp` profile and is protected by Cloud Run's `--no-allow-unauthenticated` setting, which requires a valid Google identity token on every request.
- **Known limitation:** `SENDGRID_API_KEY` (`spring.mail.password`) and `GEMINI_API_KEY` (`spring.ai.*.api-key`) are not refreshable at runtime. Spring Boot auto-configures `JavaMailSender` and the Spring AI `ChatClient` as plain singletons outside `@RefreshScope`, so they do not pick up a rotated secret without a redeployment. Making them refreshable would require defining custom `@RefreshScope` beans for both, which is achievable but adds complexity that is not warranted at the current scale.
- Gmail SMTP (`smtp.gmail.com`) does not work from Cloud Run: Google blocks or rejects SMTP authentication from its own cloud IP ranges to prevent spam, returning `535 5.7.8 BadCredentials` even with valid app passwords. The same credentials work fine from a local machine. SendGrid is used instead.

## Running locally

- Set the following environment variables in your shell:
  - `GEMINI_API_KEY`: a valid Gemini API key
  - `SENDGRID_API_KEY`: a valid SendGrid API key
- Run the application with `./mvnw spring-boot:run`.
- Call `GET http://localhost:8080/news` to trigger a Gemini prompt and receive the generated response.
- Call `POST http://localhost:8080/news/mail` to fetch news from Gemini and send it by email.
- Without `GEMINI_API_KEY`, the application starts with a placeholder key; calls to `/news` or `/news/mail` will fail with an authentication error from the Gemini API.
