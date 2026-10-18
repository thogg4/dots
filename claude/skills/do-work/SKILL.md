---
name: do-work
description: Run the full Development Workflow for any code change — from session naming through review. Use for every task that touches code, no matter how small, not just when the user invokes /do-work. Also use when the user kicks off a feature, bug fix, or refactor, or asks to "start a task" or "follow the full workflow." Creates a tracked 12-step checklist and gates progression so no step is skipped or reordered.
---

# Development Workflow

Orchestrate the full 12-step workflow for every code change, regardless of size. Per `~/.claude/rules/do-work-always.md`, invoke this skill proactively as soon as a task will touch code — don't wait for the user to run `/do-work`. Each step must be completed and verified before moving to the next.

The substance for each step lives in slash commands, other skills, or rule files (already loaded in global context). This skill is the orchestrator — keep work moving through the checklist, do not duplicate guidance from those sources.

The session itself stays on a single model throughout, whichever the user is currently running. There are no model-switch steps. Subagents are the exception: they run on whatever model the skill that spawns them specifies (e.g. `planning-team` puts its roles on Opus).

## On invocation

1. Create a task list containing all 12 steps below, in order, using whichever task-tracking tool the harness exposes (e.g., `TaskCreate`, `TodoWrite`). Use the step titles verbatim so progress is legible to the user.
2. As you finish each step, mark it completed and move the next step to in progress. Do not batch updates.

Do not collapse, reorder, or skip steps. If a step is genuinely not applicable (e.g., no UI to manually test), state why in one sentence and mark it completed.

## Keep going until done

Run the workflow through to the Final report in one continuous pass. Do not end your turn between steps to summarize progress, ask "should I continue?", or wait for acknowledgement. Finishing a step means starting the next one.

Stop only when you need an answer only the user can give:
- A gate the steps below define: a session name (Step 1), task readiness (Step 3), plan acceptance (Step 4), or the user's review (Step 11).
- A question whose answer changes what you build, or a destructive, irreversible, or outward-facing action that needs permission.

For anything else, such as naming, defaults, or choosing between equivalent approaches, pick a reasonable option, note it, and keep going. When a check fails, fix it and continue rather than reporting the failure and stopping. When you do stop, ask the question plainly. Once it's answered, pick up where you left off.

## Steps

### 1. Rename
The Claude Code session should be named after the task or ticket. If the session has no custom name yet, ask the user to set one or suggest one (e.g., from the ticket ID or feature name).

### 2. Branch
Check the current git branch. If it's the repository's default branch (e.g. `main`/`master`), create and check out a new feature branch before making any changes, named after the task or ticket (reuse the session name from Step 1, kebab-cased). If a non-default (feature) branch is already checked out, keep working on it — don't create a new one. Also create a new git worktree if there is a .claude/worktrees/ directory.

### 3. Validate work
Run the `/validate-work` skill. Confirm the task is ready for development before advancing.

### 4. Plan
Invoke the `planning-team` skill and follow it. Do not advance until the plan has been presented to and accepted by the user.

### 5. Build
Follow the **Planning and Building** guidelines (`~/.claude/rules/planning-and-building.md`) and invoke the `test-driven-development` skill. Don't run `git commit` — the user commits all changes manually.

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
- Then a `Why?` section and a `What?` section (with equals signs under the section headers), answering those two questions about the change.
- Voice: casual, succinct. No em dashes.

## Final report

Once all steps are complete, send a single summary to the user with:
- A checklist showing the status of all 12 steps (completed / skipped-with-reason)
- The generated PR description
- Anything that needs the user's attention before merge
