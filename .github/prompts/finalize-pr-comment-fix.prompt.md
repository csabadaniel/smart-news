---
name: "Finalize PR Comment Fix"
description: "Use when: commit current fix, push it, reply to the PR comment, and resolve that review thread."
argument-hint: "PR number and review comment URL or comment ID"
agent: "agent"
---
Finalize a pull request comment fix that is already implemented in the current branch.

Workflow:
1. Confirm there are intended local changes for the targeted comment.
2. Commit with a clear, scoped message.
3. Push to origin.
4. Reply to the specified PR review comment with:
   - what was fixed
   - commit hash
5. Resolve the corresponding review thread.
6. Verify final state and report.

Output requirements:
- Commit hash
- Push status
- Reply URL
- Thread resolved status
- Current branch status

Constraints:
- If comment URL/ID is missing, infer it from conversation history (recent PR comment fixes, open files, git diff) before asking. Only stop and ask if it cannot be determined from context.
- Do not touch unrelated files.
- Do not merge PR.
