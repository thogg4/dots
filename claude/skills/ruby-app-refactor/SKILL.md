---
name: ruby-app-refactor
description: Incrementally improve a Rails codebase's health by running the rails-audit-thoughtbot audit, picking one high-value finding, refactoring to resolve it, and opening a draft PR. Use when the user invokes /ruby-app-refactor or asks for a code health pass on a Rails project. Designed for small, targeted improvements — one finding per run.
---

# Ruby App Refactor

Resolve one high-value audit finding per run. Keep the change small enough to review in a single sitting — usually one file, but a few files are fine when resolving one pattern across the codebase, as long as the diff stays tight. This is a standalone, low-stakes improvement — not a fix for a specific bug or ticket.

This routine runs **autonomously** (on a schedule; the user cannot answer mid-run). Wherever a downstream skill would pause to ask a question, pre-decide the answer per the instructions below and keep going — never stall waiting for input.

## Preconditions

- Project is a Ruby on Rails app (the audit is Rails-oriented).
- The `rails-audit-thoughtbot` skill is available (cloned into `~/.claude/skills` at setup time).
- The project bundles `rubycritic` and `simplecov`, or they can be installed — the audit's metric subagents use them. If neither is available, the audit still runs on manual analysis alone.
- The `wt` (worktrunk) CLI is installed — all work happens in a worktree, not the main checkout.

## Workflow

### 1. Create a Worktree

Use `wt` to create a dedicated worktree with a predictable, dated branch name so repeated runs don't collide and PRs are easy to find later:

```bash
wt switch --create tim/refactor/automated-$(date +%Y-%m-%d)
```

This creates the worktree, checks out the new branch, and switches you into it. All subsequent steps run inside the worktree. If `wt` is not installed or fails, stop and tell the user.

### 2. Run the Audit

Invoke the `rails-audit-thoughtbot` skill to produce `RAILS_AUDIT_REPORT.md`. Run the **full pipeline** — both the SimpleCov and RubyCritic metric subagents — scoped to the implementation directories `app/` and `lib/` (a targeted audit; skip `config/`, `db/`, and generated code).

Because this routine is autonomous, **do not call the audit skill's Step 2 `AskUserQuestion` tool** — it would block forever with no one to answer. Skip that prompt entirely and proceed with these fixed choices:
- **Scope**: targeted audit of `app/` and `lib/`.
- **Metrics**: run both the SimpleCov and RubyCritic subagents.

Likewise skip the audit's Step 1 scope question — the scope is fixed above.

If a metric tool can't run (not installed and can't be added, suite won't boot), let the audit fall back to manual analysis for that tool and carry on — a missing metric is not a reason to abort the run.

Keep the resulting `RAILS_AUDIT_REPORT.md` and the parsed RubyCritic/SimpleCov data in context — you'll use the report and RubyCritic data to pick a finding (Step 3) and the SimpleCov data to gauge test coverage (Step 4).

### 3. Pick One Finding

From the report, pick **one** finding to resolve. Prefer, in order:

1. **High**, then **Medium** severity findings.
2. Findings in the **Code Design & Architecture**, **Models**, **Controllers**, or **Views** categories — maintainability smells (long methods, large classes, feature envy, duplication, PHPitis) that are self-contained and safe to refactor autonomously.

Constrain the pick so the change stays **small and easily reviewable**:
- Prefer a finding confined to one implementation file in `app/` or `lib/` (touching its spec is expected). Spanning a few files is fine when you're resolving **one pattern** — e.g. the same smell repeated across a handful of related classes — as long as the diff stays tight and focused on that single finding. Skip anything that would sprawl into a large diff touching many unrelated files.
- Favor findings the RubyCritic data corroborates (a D/F rating or high-complexity/duplication file) — these are the highest-confidence targets.

**Skip** these — they don't fit an autonomous, low-stakes refactor pass:
- **Critical** and security findings (SQL injection, mass assignment, XSS, auth). These need dedicated, carefully-reviewed fixes, not an automated draft PR. Note them in the final report so the user can ticket them, but don't act on them here.
- Migrations, seeds, vendored code, generated code.
- Files with recent commits from other contributors or that appear in open PRs — check `git log -- <file>` and `gh pr list --search "<file>"` for each file you plan to touch.
- Files refactored in a recent run — check `gh pr list --state all --search "tim/refactor/automated in:title" --limit 10`.

If no finding looks safe to act on, report that (surfacing any Critical/security findings) and stop. Skipping a run is fine.

### 4. Assess Test Coverage

Find the corresponding spec file (e.g., `spec/.../<file>_spec.rb`). Use the SimpleCov data from the audit to gauge where coverage is thin.

- **No specs (0% coverage):** Add meaningful coverage for the behavior you're about to touch before refactoring. You need a safety net.
- **Sparse specs:** Fill in coverage for the code paths you plan to change.
- **Good coverage:** Proceed.

Run the relevant tests and confirm they pass before changing any production code. A green baseline is required.

### 5. Refactor

Invoke the `test-driven-development` skill and follow it. Make one focused change at a time and keep tests green between steps.

Target the specific finding you picked. Let the report's recommendation and the thoughtbot reference guides shipped with the audit skill (`references/code_smells.md`, `references/rails_antipatterns.md`, `references/poro_patterns.md`) inform the fix. Common useful moves:
- Extract method for long or high-complexity methods
- Extract a PORO (ActiveModel) for a fat model or service object
- Move view logic into a helper or presenter
- Rename poorly-named methods or variables
- Remove dead code
- Consolidate duplicated logic

Resist the urge to clean up unrelated code in the same PR. Keep the diff tight so the reviewer can evaluate it quickly.

If the finding turns out not to be cleanly resolvable — the refactor balloons, gets risky, or you can't keep tests green — abandon it, reset the branch, and pick another finding from the report. If no candidate pans out, reset the branch, remove the worktree, and report the run as a no-op (this is allowed). Otherwise continue — do **not** stop to ask whether to proceed.

### 6. Run Project Checks

Run the project's full check command (typically `chp` or equivalent) and confirm everything is green before opening a PR.

### 7. Review

Invoke the `/review` skill to run the code review suite against the refactor. Address any feedback it surfaces before moving on.

### 8. Create a Draft PR

**Always open the draft PR** once the refactor resolves the finding and the checks pass. This routine runs autonomously and the user cannot answer mid-run, so never stop to ask whether to open the PR — open it and surface any concerns *in the PR body* and the final report instead. The draft state and the user's review are the safety net; a draft PR they can read and act on is far more useful than a paused run they can't reach.

Invoke the `/create-pr` skill to open the PR in the current repository. Provide this context to that skill:

- **Title:** `Automated Refactor by Claude: <what changed>` — name the primary file when the change is one file (include 1 or 2 parent directories if the base name alone is ambiguous), or the pattern/area when it spans a few (e.g. `Automated Refactor by Claude: extract Notifier POROs`).
- **No ticket** — this is an automated code health pass, not a ticketed change. Skip the "Contributes to..." line in the description.
- **Body highlights:**
  - The audit finding addressed: its category, severity, and the smell/antipattern, and how the refactor resolves it
  - Any concerns or caveats the reviewer should weigh (e.g. limited test coverage, files you considered but couldn't safely touch)
  - Any **Critical/security findings** the audit surfaced that this pass deliberately left alone, so the user can ticket them
  - Note that the PR was generated by the `/ruby-app-refactor` skill
- **Keep it a draft.** The user reviews and promotes it to ready when appropriate.

Do not commit `RAILS_AUDIT_REPORT.md` — it's a working artifact. Delete it (and any leftover `coverage/` or `tmp/rubycritic/`) before opening the PR.

### 9. Deploy to Stage

Follow the Stage Deployment guidelines to merge the branch into `stage`, run checks, push, and monitor. This lets the user test the refactor in a running environment before merging the PR.

**Override the Stage Deployment rule's confirmation step.** This routine runs autonomously, so do *not* pause to ask the user for a go-ahead before pushing to stage — that step in the global Stage Deployment rule does not apply here. Push without waiting for confirmation.

### 10. Report

After the PR is open and stage is deployed, tell the user:
- File(s) refactored and the audit finding they resolved (category + severity), and how the refactor addresses it
- Any Critical/security findings the audit surfaced but this pass left for the user to ticket
- Any other concerns or caveats (same ones flagged in the PR body)
- PR URL
- Stage deploy status
