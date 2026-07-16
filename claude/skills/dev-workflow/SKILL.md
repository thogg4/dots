---
name: dev-workflow
description: Run the full Development Workflow for a non-trivial task — from session naming through stage deployment. Use when the user invokes /dev-workflow, kicks off a non-trivial feature, bug fix, or refactor, or asks to "start a task" or "follow the full workflow." Creates a tracked 13-step checklist and gates progression so no step is skipped or reordered.
---

# Development Workflow

Orchestrate the full 13-step workflow for non-trivial tasks. Each step must be completed and verified before moving to the next.

The substance for each step lives in slash commands, other skills, or rule files (already loaded in global context). This skill is the orchestrator — keep work moving through the checklist, do not duplicate guidance from those sources.

This workflow runs on two models: **Fable** for planning and **Opus** for building and everything after. Claude Code cannot change its own model — only the user can, via `/model`. You know which model you're running from the session context, so at the two model-switch steps your job is to detect a mismatch and ask the user to switch, then wait for them to confirm before advancing.

## On invocation

1. Create a task list containing all 13 steps below, in order, using whichever task-tracking tool the harness exposes (e.g., `TaskCreate`, `TodoWrite`). Use the step titles verbatim so progress is legible to the user.
2. As you finish each step, mark it completed and move the next step to in progress. Do not batch updates.

Do not collapse, reorder, or skip steps. If a step is genuinely not applicable (e.g., no UI to manually test), state why in one sentence and mark it completed.

## Steps

### 1. Switch to Fable
Planning runs on Fable. If you are not already running Fable, stop and ask the user to switch to Fable via `/model` before doing anything else. If you're already on Fable, say so and proceed.

### 2. Rename
The Claude Code session should be named after the task or ticket. If the session has no custom name yet, ask the user to set one or suggest one (e.g., from the ticket ID or feature name).

### 3. Validate work
Run the `/validate-work` skill. Confirm the task is ready for development before advancing.

### 4. Plan
Invoke the `planning-team` skill and follow it. Do not advance until the plan has been presented to and accepted by the user.

### 5. Switch to Opus
Building runs on Opus. Now that the plan is approved and before writing any code, check your current model. If you are not running Opus, ask the user to compact the conversation and then switch to Opus via `/model`. Compacting is worthwhile here because switching models discards the prompt cache anyway, so there's no caching benefit to preserve. Also ask the user to consider what reasoning effort level is appropriate for the task. Do not advance to Build until the user confirms.

### 6. Build
Follow the **Planning and Building** guidelines (`~/.claude/rules/planning-and-building.md`) and invoke the `test-driven-development` skill. Commit regularly per the git rules.

### 7. Manual testing
Follow the **Manual Testing** guidelines (`~/.claude/rules/manual-testing.md`). Verify the happy path and relevant edge cases.

### 8. Automated testing
Follow the **Automated Testing** guidelines (`~/.claude/rules/automated-testing.md`). Confirm coverage is solid and tests run cleanly.

### 9. CI checks
Confirm tests, linters, and other checks pass. In most projects this is `chp`. Fix any failures before proceeding.

### 10. Simplify
Run the `/simplify` skill. **For Rails projects**, also launch `@rails-simplifier:rails-simplifier` in parallel.

### 11. Review
Run the `/review` skill. Address feedback; re-run targeted reviewers if follow-up is warranted.

### 12. User review
Once your own work and reviews are complete and you're confident the code is ready, hand it off to the user for review — the local equivalent of opening a pull request for a human reviewer. Ask them to review the work and go through their Code Review for Agent Generated Code checklist (`omarchy/snippets/crag-code-review-agent-generated-code.md`; its `;pgr` line expands from `omarchy/snippets/pgr-plannotator-guided-review.md` via the snippet picker). Wait for the user to sign off before advancing. Do not proceed to the stage deploy until they have explicitly signed off.

### 13. Stage deploy
Invoke the `stage-deployment` skill and follow it. Do not notify the user until the stage deploy is live and smoke tested.

## Final report

Once all steps are complete, send a single summary to the user with:
- A checklist showing the status of all 13 steps (completed / skipped-with-reason)
- The stage URL and any smoke-test notes
- Anything that needs the user's attention before merge
