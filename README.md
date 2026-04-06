# smart-news

## Project Goal

Build a reliable scheduled service that prompts Gemini and sends the generated result by email, with a setup that is simple to operate, secure, and cost-aware for Google Cloud free-tier-friendly deployment.

## Tech Stack

- Java 21 LTS (initial baseline), with planned upgrade validation for Java 25 LTS
- Spring Boot (version TBD; must support Java 21 baseline and planned validation on Java 25 LTS)
- Spring AI
- Maven
- Lombok
- Gemini API (Google AI)
- Email delivery via SMTP or email API provider
- Docker
- GitHub Actions
- Google Cloud: Cloud Run (container runtime), Cloud Scheduler, Artifact Registry, Secret Manager, Parameter Manager

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
| 04  | Integrate with Gemini API for content generation          | iteration/04-gemini-integration        | Completed   |
| 05  | Integrate email sending                                   | iteration/05-email-integration         | In Progress |

## Deploy to GCP Cloud Run

### Setup

- GitHub Actions secrets (Settings -> Secrets and variables -> Actions):
  - `GCP_PROJECT_ID`
  - `GCP_WORKLOAD_IDENTITY_PROVIDER`
  - `GCP_SERVICE_ACCOUNT`
- GCP Secret Manager secrets:
  - `gemini-api-key`: the Gemini API key used by the service on Cloud Run
  - `gmail-username`: the Gmail address used as SMTP username, sender, and recipient
  - `gmail-app-password`: the Gmail app password used for SMTP authentication
- GCP Parameter Manager parameters (global):
  - `smart-news-model` (latest): the Gemini model name (e.g. `gemini-2.5-flash`)
  - `smart-news-prompt` (latest): the prompt sent to Gemini on each `/news` request

### Non-obvious behavior

- Build runs on every push and pull request.
- Deployment runs only on manual `workflow_dispatch` requests and pushes to `main`.
- Deployment does not require a separate approval step.
- Docker image is pushed to Artifact Registry as part of the deploy job.
- `GEMINI_API_KEY` is mounted from GCP Secret Manager on Cloud Run; it is not set as a plain environment variable.
- The `gcp` Spring profile is activated on Cloud Run; it enables GCP Parameter Manager to supply the model name and prompt at runtime.
- Prompt and model can be updated without redeployment by creating a new parameter version and calling `POST /actuator/refresh`. The endpoint is only exposed under the `gcp` profile and is protected by Cloud Run's `--no-allow-unauthenticated` setting, which requires a valid Google identity token on every request.

## Running locally

- Set the following environment variables in your shell:
  - `GEMINI_API_KEY`: a valid Gemini API key
  - `GMAIL_USERNAME`: the Gmail address used as SMTP username, sender, and recipient
  - `GMAIL_APP_PASSWORD`: a Gmail app password for SMTP authentication
- Run the application with `./mvnw spring-boot:run`.
- Call `GET http://localhost:8080/news` to trigger a Gemini prompt and receive the generated response.
- Call `POST http://localhost:8080/news/mail` to fetch news from Gemini and send it by email.
- Without `GEMINI_API_KEY`, the application starts with a placeholder key; calls to `/news` or `/news/mail` will fail with an authentication error from the Gemini API.
