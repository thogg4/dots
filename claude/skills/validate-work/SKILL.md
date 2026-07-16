---
name: validate-work
description: Validate that a task or ticket is ready for development before planning and building. Use when the user invokes /validate-work, when the Development Workflow calls for the work-validation step, or when the user asks whether a task is ready to start. Checks for attached documentation and requirement readiness, then reaches a ready / not-ready verdict with the user.
---

# Validate Work

Before investing in planning and building, confirm the ticket/task is actually ready for development. The key question this step answers: **is this work ready to start, or should it go back to someone else for more definition first?**

Do not advance until you've worked through both checks below and reached a clear verdict with the user.

## Documentation Check

Confirm the task has relevant documentation attached. The instructions you were given — or the Linear issue description, if the task came from one — should include links to relevant documentation (framework docs, API references, internal runbooks, design specs, etc.). Having docs upfront improves quality at every later step.

If no documentation was provided, that's likely an oversight. Identify what documentation would be relevant and helpful for this task, then ask the user to provide it before proceeding.

## Readiness Check

Evaluate whether the task is well-enough defined to build:

- **Do we know what we're building?** Check for sufficient detail about the intended user experience, the business process, and the expected behavior. If the task is vague about what the end result should look like or do, that's a concern.
- **Open questions, unknowns, and ambiguity.** Actively surface these — don't paper over them. List every open question and ambiguous requirement you can find. A few are normal; a pile of them means the task isn't ready. We're less concerned about technical questions and unkowns; it's our job to figure those out. Primarily, we're concerned about requirements, business needs, user experience, etc.
- **Time estimate vs. scope.** Estimate how long the task should take, and sanity-check that against the expected timeframe. If the work doesn't realistically fit, the task probably needs to be broken down into smaller pieces first.

## Decision

State a clear verdict:

- **Ready** — documentation is attached, we know what we're building, open questions are minimal, and the scope fits the timeframe. Proceed to the next step.
- **Not ready** — surface the specific gaps (missing docs, unresolved questions, oversized scope) and recommend the task go back for additional definition or to be broken down before development starts. Don't push forward on an underdefined task just to keep momentum.
