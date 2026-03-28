# Contributing

## Commit Message Convention

This repository uses **Conventional Commits** format for all commit messages.

### Pattern
```
<type>: <subject>
```

### Types
- `feat:` — new feature
- `fix:` — bug fix
- `ci:` — CI/CD workflow changes
- `docs:` — documentation updates
- `refactor:` — code refactoring
- `test:` — test-related changes
- `build:` — build system changes
- `chore:` — maintenance tasks

### Examples
- `ci: add workflow_dispatch trigger to build workflow`
- `docs: mark iteration 03 in progress and align statuses`
- `feat: build base service with actuator health endpoint (#4)`
- `fix: correct Maven configuration for Java 21`

### Guidelines
- Use lowercase type prefix
- Follow with colon and space
- Use imperative mood (e.g., "add" not "added")
- Do not end with a period
- Be descriptive but concise

## Testing Strategy

This project uses **London School Test-Driven Development (TDD)** for implementation.

### London School TDD Principles
- **Test-first approach**: Write tests before implementation
- **Behavior-driven**: Focus on what the code should do, not implementation details
- **Mock dependencies**: Use mocks and stubs to isolate units under test
- **Outside-in development**: Start from the public API and work inward
- **Collaboration through tests**: Tests serve as executable specifications and living documentation

### Testing Guidelines
- Write unit tests for all public methods and services
- Use mocks for external dependencies (APIs, databases, file systems)
- Name tests descriptively: Use imperative mood (e.g., `shouldGenerateNewsFromValidPrompt`, `throwsExceptionForInvalidInput`)
- Keep tests focused on behavior, not implementation
- Ensure tests are deterministic and isolated
- Aim for high test coverage on business logic and services

## Deployment Policy

- Current setup deploys a single production service.
- CI build and Docker verification run on every push and pull request.
- Deployments run only when triggered manually via `workflow_dispatch` or automatically from pushes to `main`.
- Deployments do not require a separate approval step.
