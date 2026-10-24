---
name: create-pr
description: Create a GitHub pull request with a structured description. Use when the user invokes /create-pr, asks to create a PR, or when the Development Workflow calls for PR creation. Handles pre-flight checks, PR template detection, and description generation.
---

# Create PR

Create a draft GitHub pull request with a structured description.

## Instructions

### 1. Pre-flight Checks

Complete each item before creating the PR. Skip items 1-3 when the caller asks you to:

1. **Confirm target branch** — Ask the user which branch to merge into if not obvious from context. When skipped, use the repo's default branch.
2. **Confirm tasks complete** — Ask the user to confirm all planned tasks are done.
3. **Confirm feature flags** — Ask if any feature flags are needed.
4. **Run project checks** — Run the project's check command (typically `chp` or equivalent). Do not proceed if checks fail.

### 2. Gather Context

Run these in parallel:

```bash
git status
git log --oneline <base-branch>..HEAD
git diff <base-branch>...HEAD --stat
```

Also check for a PR template:

```bash
# Check common locations
cat .github/pull_request_template.md 2>/dev/null || \
cat .github/PULL_REQUEST_TEMPLATE.md 2>/dev/null || \
cat docs/pull_request_template.md 2>/dev/null || \
cat PULL_REQUEST_TEMPLATE.md 2>/dev/null
```

If a repo PR template exists, use its structure instead of the default template below.

### 3. Determine PR Title and Ticket Info

- If the caller provided a title and description, use them for the title and the Why?/What? sections. Otherwise ask the user for the ticket ID and title if not already known from context (branch name, commit messages, Linear, etc.).
- Format the PR title as: `TICKET-ID / title` (e.g. `DEV-1234 / fix login redirect`). If there's no ticket ID, just use `title`. Keep it to 256 characters or fewer (GitHub's PR title limit).
- Determine the ticket URL for linking in the description.

### 4. Create the Draft PR

Push the branch if needed, then create the PR with `gh pr create --draft --assignee @me`.

**PR description structure:**

```
Why?
====
Contributes to [TASK_ID](task_url)

- Why is this change being made?

What?
=====
- What actually changed?
```

**Guidelines for the description:**
- Voice: casual, succinct. No em dashes.
- Keep the Why?/What? sections short — don't go overboard on details.
- Don't add checklists of your own (a repo PR template's sections stay as-is), or a note or footer saying Claude created the PR unless the caller asks for one.
- Use a HEREDOC to pass the body to `gh pr create` for correct formatting.

### 5. Report Results

Show the user the PR URL.
