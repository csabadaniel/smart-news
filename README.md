# smart-news

## Project Goal

Build a reliable scheduled service that prompts Gemini and sends the generated result by email, with a setup that is simple to operate, secure, and cost-aware for Google Cloud free-tier-friendly deployment.

## Tech Stack

- Java 21 LTS (initial baseline), with planned upgrade validation for Java 25 LTS
- Spring Boot (version TBD; must support Java 21 baseline and planned validation on Java 25 LTS)
- Maven
- Gemini API (Google AI)
- Email delivery via SMTP or email API provider
- Docker
- GitHub Actions
- Google Cloud: Cloud Run (container runtime), Cloud Scheduler, Artifact Registry, Secret Manager

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

| #   | Goal                                                      | Branch                                 | Status      |
| --- | --------------------------------------------------------- | -------------------------------------- | ----------- |
| 01  | Document project intent and workflow                      | iteration/01-project-intent            | Completed   |
| 02  | Build the base service responding to an external API call | iteration/02-base-service-external-api | Completed   |
| 03  | Deploy the base service to GCP Cloud Run                  | iteration/03-deploy-to-gcp             | Completed   |
| 04  | Integrate Gemini API to generate content from a prompt    | iteration/04-gemini-api-integration    | In Progress |

## Deploy to GCP Cloud Run

### Setup

- GitHub Actions secrets (Settings -> Secrets and variables -> Actions):
  - `GCP_PROJECT_ID`
  - `GCP_WORKLOAD_IDENTITY_PROVIDER`
  - `GCP_SERVICE_ACCOUNT`

### Non-obvious behavior

- Build runs on every push and pull request.
- Deployment runs only on manual `workflow_dispatch` requests and pushes to `main`.
- Deployment does not require a separate approval step.
- Docker image is pushed to Artifact Registry as part of the deploy job.
