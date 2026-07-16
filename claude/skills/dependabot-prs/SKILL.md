---
name: dependabot-prs
description: Process open Dependabot pull requests for any GitHub repository. Use when the user invokes /dependabot-prs, asks to process Dependabot PRs, or wants to review and stage dependency updates. Fetches open Dependabot PRs, reviews changelogs for breaking changes, merges safe updates into the stage branch, adds review comments, and identifies previously-staged PRs ready for final merge.
---

# Dependabot Manager

Process open Dependabot PRs by reviewing changelogs, merging into stage, and commenting with findings.

## Workflow

1. Discover open Dependabot PRs
2. For each PR, review the changelog and assess risk
3. Merge safe PRs into stage and push
4. Comment on each PR with findings
5. Identify previously-staged PRs ready for final merge

### 1. Discover Open Dependabot PRs

```bash
gh pr list --author "app/dependabot" --state open --json number,title,headRefName,body,createdAt,comments
```

If no PRs are found, report that and stop.

Present a summary table of all open Dependabot PRs:
- PR number, title, and age

### 2. Review Each PR

For each PR:

1. **Read the PR body** — Dependabot includes release notes, changelog entries, and commit history in the PR description.
2. **Fetch the full changelog if needed** — If the PR body lacks sufficient detail, check the dependency's repository for a CHANGELOG or release notes using `gh` or web fetch.
3. **Assess risk:**
   - **Safe (minor/patch, no breaking changes):** Proceed to merge into stage.
   - **Needs attention (major version bump, breaking changes, deprecations):** If reasonable and not too large, address the compatibility issues in a new commit on the dependabot branch and push it up. If you're unsure of how to proceed safely, add a comment to the PR describing the specific compatibility concerns and ask the user for guidance.
4. If appropriate, do some manual testing to verify things are still working correctly. For example, if we're upgrading the pagination gem, manually test pagination using Chrome.

### 3. Merge Safe PRs into Stage

For each PR assessed as safe, merge the branch into the `stage` branch and push
to deploy to the stage environment. Batch multiple safe PRs by merging them all
into `stage` before pushing to minimize CI runs.

**Override the Stage Deployment rule's confirmation step.** This routine runs
autonomously, so do *not* pause to ask the user for a go-ahead before pushing to
stage — that step in the global Stage Deployment rule does not apply here. Push
safe updates without waiting for confirmation.

If a merge conflict occurs, resolve it if you can; let the user know if you can't.

After pushing, monitor the deployment in GitHub CI and confirm it succeeds.

### 4. Comment on Each PR

After merging into stage, add a brief comment to the PR via `gh pr comment`. The comment should:

- State the risk level and any specific concerns
- Note it was merged into stage and how long it will stay there before being eligible for production
- Be succinct — a few sentences, not a formatted report

### 5. Identify PRs Ready for Final Merge

Check existing PR comments for previously-staged Dependabot PRs. For each candidate:

1. **Check timing** — confirm sufficient time has passed since staging:
   - **Patch/minor updates, or major updates in a development/test-only dependency:** 20+ hours (the staging cadence is daily, so morning-to-morning runs may land just under 24)
   - **Major updates affecting production:** At least 1 week
2. **Check Rollbar** — use the Rollbar MCP server (`list-items`, `get-top-items`) to look for recent errors in the stage environment that could be related to the dependency update.
3. **Determine readiness and comment on the PR:**
   - **Ready:** No related errors in Rollbar, sufficient time has passed. Add a comment stating the update has been in stage since [date], no related errors were found in Rollbar, and the PR is ready to merge into production.
   - **Insufficient time:** Skip — do nothing. It will be checked again on the next run.
   - **Errors found:** Related errors in Rollbar. Add a comment to the PR with the Rollbar findings and flag to the user.

## Important

- **When in doubt, ask** — If a changelog mentions breaking changes, deprecations, or anything unusual, flag it rather than assuming it's safe.
- **Be specific in comments** — Summarize the actual changes from the changelog.
