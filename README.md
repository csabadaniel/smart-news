# smart-news

## Project Goal

Build a reliable scheduled service that prompts Gemini and sends the generated result by email, with a setup that is simple to operate, secure, and cost-aware for Google Cloud free-tier-friendly deployment.

## Tech Stack

- Java 21 LTS (initial baseline), with planned upgrade validation for Java 25 LTS
- Spring Boot 4.0.x (latest stable line; compatible with Java 17-25)
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
