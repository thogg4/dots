---
name: dev-workflow
description: Run the full Development Workflow for any code change — from session naming through review. Use for every task that touches code, no matter how small, not just when the user invokes /dev-workflow. Also use when the user kicks off a feature, bug fix, or refactor, or asks to "start a task" or "follow the full workflow." Creates a tracked 12-step checklist and gates progression so no step is skipped or reordered.
---

# Development Workflow

Orchestrate the full 12-step workflow for every code change, regardless of size. Per `~/.claude/rules/dev-workflow-always.md`, invoke this skill proactively as soon as a task will touch code — don't wait for the user to run `/dev-workflow`. Each step must be completed and verified before moving to the next.

The substance for each step lives in slash commands, other skills, or rule files (already loaded in global context). This skill is the orchestrator — keep work moving through the checklist, do not duplicate guidance from those sources.

This workflow runs entirely on a single model, whichever the user is currently running. There are no model-switch steps.

## On invocation

1. Create a task list containing all 12 steps below, in order, using whichever task-tracking tool the harness exposes (e.g., `TaskCreate`, `TodoWrite`). Use the step titles verbatim so progress is legible to the user.
2. As you finish each step, mark it completed and move the next step to in progress. Do not batch updates.

Do not collapse, reorder, or skip steps. If a step is genuinely not applicable (e.g., no UI to manually test), state why in one sentence and mark it completed.

## Steps

### 1. Rename
The Claude Code session should be named after the task or ticket. If the session has no custom name yet, ask the user to set one or suggest one (e.g., from the ticket ID or feature name).

### 2. Branch
Check the current git branch. If it's the repository's default branch (e.g. `main`/`master`), create and check out a new feature branch before making any changes, named after the task or ticket (reuse the session name from Step 1, kebab-cased). If a non-default (feature) branch is already checked out, keep working on it — don't create a new one.

### 3. Validate work
Run the `/validate-work` skill. Confirm the task is ready for development before advancing.

### 4. Plan
Invoke the `planning-team` skill and follow it. Do not advance until the plan has been presented to and accepted by the user.

### 5. Build
Follow the **Planning and Building** guidelines (`~/.claude/rules/planning-and-building.md`) and invoke the `test-driven-development` skill. Commit regularly per the git rules.

### 6. Manual testing
Follow the **Manual Testing** guidelines (`~/.claude/rules/manual-testing.md`). Verify the happy path and relevant edge cases.

### 7. Automated testing
Follow the **Automated Testing** guidelines (`~/.claude/rules/automated-testing.md`). Confirm coverage is solid and tests run cleanly.

### 8. CI checks
Confirm tests, linters, and other checks pass. In most projects this is `chp`. Fix any failures before proceeding.

### 9. Simplify
Run the `/simplify` skill. **For Rails projects**, also launch `@rails-simplifier:rails-simplifier` in parallel.

### 10. Review
Run the `/review` skill. Address feedback; re-run targeted reviewers if follow-up is warranted.

### 11. User review
Once your own work and reviews are complete and you're confident the code is ready, hand it off to the user for review — the local equivalent of opening a pull request for a human reviewer. Ask them to review the work and go through their Code Review for Agent Generated Code.

### 12. PR description
Generate a description for the pull request:
- First line is the title: `TICKET-ID / title` if a ticket ID was given (Step 1), otherwise just `title`.
- Then a `## Why?` section and a `## What?` section, answering those two questions about the change.
- Voice: casual, succinct. No em dashes.

## Final report

Once all steps are complete, send a single summary to the user with:
- A checklist showing the status of all 12 steps (completed / skipped-with-reason)
- The generated PR description
- Anything that needs the user's attention before merge
