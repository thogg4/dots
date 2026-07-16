---
name: create-pr
description: Create a GitHub pull request with a structured description. Use when the user invokes /create-pr, asks to create a PR, or when the Development Workflow calls for PR creation. Handles pre-flight checks, PR template detection, description generation, and post-creation checklist.
---

# Create PR

Create a draft GitHub pull request with a structured description following the team's PR workflow.

## Instructions

### 1. Pre-flight Checks

Complete each item before creating the PR:

1. **Confirm target branch** — Ask the user which branch to merge into if not obvious from context.
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

If a repo PR template exists, use its structure for the middle section (between the before/after checklists) instead of the default template below.

### 3. Determine PR Title and Ticket Info

- Ask the user for the ticket number and title if not already known from context (branch name, commit messages, Linear, etc.).
- Format the PR title as: `#{ticket_number} - #{ticket_title}`
- Determine the ticket URL for linking in the description.

### 4. Create the Draft PR

Push the branch if needed, then create the PR.

**PR description structure:**

```
## Goal
Contributes to [TASK_ID](task_url)

- What is the goal and purpose of these changes?

## Primary Changes
- Most important changes for the reviewer

## Tradeoffs & Alternatives
- Other approaches considered and tradeoffs made

## Things to Look Out for While Reviewing
- Areas needing special attention

## Needed Supporting Changes
- Required changes in other systems or deployment steps

## Testing
- How the reviewer should test (don't suggest running automated tests; CI does that)

## Demo

<details>
  <summary>Some Image</summary>
  <img src="" />
</details>

## PR Checklist
- [ ] Tested on stage
- [ ] API documentation is updated if needed

---------------------------------

## After Creating Pull Request
- [ ] Deploy to stage.
- [ ] Add pull request link to project management ticket or confirm it was automatically linked.
- [ ] Fill in description template.
- [ ] Have Claude Code review the changes if not done already. (`/review`)
- [ ] Review all of the changes. (Add comments as helpful.)
- [ ] Ensure changes are tested well.
    - Go through each implementation file and compare it to related test files. Ensure there's good coverage.
- [ ] Ensure changes are documented well.
    - README, wiki pages, inline comments, etc.
    - Add YARD docs for public methods if appropriate.
- [ ] Update Postman if needed.
- [ ] Confirm feature meets requirements.
    - Review contents of ticket.
- [ ] Add demo images and/or videos to project management ticket.
- [ ] Add QA instructions if needed.
- [ ] Test changes in stage.
- [ ] If you made changes, run project checks again and push new commits.
- [ ] Submit any comments you added during your personal review.
- [ ] Ensure CI is passing.
- [ ] Mark pull request as ready to review.
- [ ] Request reviews.
- [ ] Request QA.
- [ ] Remember to update ticket once merged.
- [ ] Remember to run migrations if needed after merging.
```

**Guidelines for the description:**
- Keep it simple and concise — don't go overboard on details.
- Omit sections that aren't relevant (e.g., skip "Tradeoffs & Alternatives" if there's nothing notable, skip "Demo" if not applicable).
- The "After Creating Pull Request" checklist is always included verbatim.
- Use a HEREDOC to pass the body to `gh pr create` for correct formatting.
- Add a short note at the top of the description making clear the PR was created by Claude on Tim's behalf (e.g. "_Created by Claude on Tim's behalf._").

### 5. Report Results

Show the user the PR URL and remind them of the "After Creating Pull Request" checklist.
