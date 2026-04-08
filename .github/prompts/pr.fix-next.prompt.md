---
name: "pr.fix-next"
description: "Use when: address the next unresolved pull request review comment and stop before commit."
argument-hint: "PR number (e.g. 4), optional owner/repo"
agent: "agent"
---
Address the next unresolved review thread on the target pull request.

Workflow:
1. Determine target PR from the argument. If owner/repo is not provided, use the current repository. If PR number is not provided, list open PRs in the repository: if there is exactly one, use it automatically; if there are multiple, stop and ask the user to specify a PR number.
2. List unresolved review threads ordered oldest first.
3. Pick the first unresolved thread.
4. Implement the minimal fix in the current branch.
5. Run verification appropriate for this repository (prefer `./mvnw verify`).
6. Stop before commit and before push.

Output requirements:
- Thread URL and short summary
- Files changed
- Validation result
- Suggested commit message following the Conventional Commits convention required by CONTRIBUTING.md:
  - Format: `<type>: <subject>` (no scope)
  - Allowed types: feat, fix, ci, docs, refactor, test, build, chore
  - Lowercase type, imperative mood subject, no trailing period

Constraints:
- Do not commit.
- Do not push.
- Do not reply on PR.
- Do not resolve the thread.
- Avoid unrelated changes.
