# Interview Question Bank

Questions to work through per section of `ticket-template.md`. Use these as starting points, not a script to read verbatim — adapt wording to what the user already said, skip a question they've already answered, and always follow up when an answer is vague rather than moving on.

A section is only "not applicable" when the user confirms that; otherwise keep asking until it's either answered or named as an open question/unknown.

## Orientation (ask first, before touching the template)

- In one or two sentences, what are we building or fixing?
- Which team does this belong to? (show real options from `list_teams` rather than asking them to recall names)
- Is this part of an existing project/initiative, or standalone? (show options from `list_projects` scoped to that team)
- Who is this for — an internal team, an external customer, a specific role? (feeds User Story)

## Background

- Why does this work exist — a decision, an incident, a prior research spike, a customer request?
- Is there prior context (a doc, a past ticket, a Slack thread) a developer would need to find? Get the link/ID.
- Skip this section only if the Description genuinely stands alone — confirm with the user before dropping it.

## User Story

- Who is the user — a specific role (developer, operator, customer, internal team)?
- What do they want to be able to do?
- Why — what breaks or what's missing without this?

## Description (unconditional — never omit)

- What's the problem being solved or the outcome being requested, in plain terms?
- Explicitly confirm: no implementation detail belongs here — redirect "how" answers to Technical Notes.

## Scope

- What's definitely included — the concrete deliverables?
- What would a reasonable reader *assume* is included but isn't? Push for specifics — "everything else is out of scope" isn't a real boundary.
- Are there adjacent asks (a related bug, a "nice to have") that should be split into a separate ticket instead of bundled here?

## Current vs. Expected Behavior

- Ask first: is this modifying or replacing existing functionality (migration, integration, bug fix)? If it's net-new, confirm and omit this section.
- If yes: what does it do today? Don't accept a description from memory alone — verify against the code (step 4 of the workflow) and cite `file:line`.
- What should it do instead, concretely?

## Non-Functional Requirements / Constraints

- Any performance expectations (latency, throughput, data volume)?
- Any security, compliance, or data-handling constraints (PII, auditing, access control)?
- Any accessibility requirements?
- Remind the user: anything testable as pass/fail belongs in Acceptance Criteria instead, not here.

## Acceptance Criteria (unconditional — never omit)

Ask the user to state criteria, then actively probe categories they didn't mention — a happy-path-only answer isn't sufficient:

- **Status Behavior** — what are the valid states/transitions?
- **Error Handling** — what happens on failure? Is it surfaced to the user, logged, retried?
- **Edge Cases** — empty input, duplicate submission, concurrent access, boundary values?
- **Data Integrity** — any invariant that must hold (uniqueness, referential integrity, idempotency)?
- **Loading / Empty States** — what does the UI or API show before data exists or while it's loading?
- **Audit & Logging** — does this need to be logged or tracked for compliance/debugging?
- **Permissions & Visibility** — who can see or trigger this? Any role restrictions?
- **UI / Modal Behavior** — for UI work: what does the user see at each step?

Skip a category only when the user confirms it genuinely can't occur — don't skip because it wasn't mentioned. Push every criterion into a single observable pass/fail statement someone else could verify without asking what was meant.

## Technical Notes

- What's the proposed technical approach, in the user's own words?
- Which files, classes, endpoints, or services are involved, as far as the user knows?
- Any existing pattern in the codebase this should follow?
- Any known risk, unverified assumption, or third-party behavior this depends on?
- After the user answers, search the local repo (if checked out) to verify and cite `file:line`, and flag anything the user said that the code contradicts. If no repo is available, say so and keep this section at the level of detail the user gave, marking it unverified.

## Estimation (unconditional — never omit)

- Does the user have their own estimate? If so, which bucket: 2 / 4 / 8 / 16 / 32 engineering hours?
- If unsure, walk through it: how many files/systems does this touch? Is this new code or modifying existing code? How much testing does this need?
- If the honest answer is above 32, say so and propose splitting the ticket rather than forcing a bucket.

## Supporting Assets

- Is there a Figma file or UI design?
- Is there a prototype?
- Any external documentation (vendor docs, API specs) this depends on?
- Any internal API/technical spec already written?
- Omit the whole section if none of these exist — don't list empty bullets.

## Open Questions / Dependencies

- What don't we know yet that the code or the user can't settle right now?
- Any product decision still pending?
- Any dependency on another team, system, or ticket?
- Anything here that blocks the work is also a Definition of Ready failure — say so explicitly rather than letting it slide.

## Related Tickets

- Does this relate to, block, or depend on other Linear issues? Get identifiers and confirm via the Linear MCP rather than trusting memory.

## QA Notes

- How should this be verified — which environment?
- Key scenarios QA should exercise by hand?
- Any test data, accounts, or fixtures needed?
- Any edge case worth a manual pass beyond the automated Acceptance Criteria?

## Additional Resources

- Any dashboard, runbook, log query, or incident report worth linking?
- Omit unless genuinely useful — don't pad this section.
