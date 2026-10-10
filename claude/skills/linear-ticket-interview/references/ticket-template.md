# Ticket Template

Use these headings, in this order, with this wording. Parenthetical text is authoring guidance — never copy it into a ticket. This is Deseret Book's standard Engineering ticket template, shared with the `work-intake` skills — don't ask the interview section by section without reading this file first; it defines what each heading means.

**Omit any section that isn't relevant.** A section with nothing real to say is noise, not diligence — drop the heading entirely rather than filling it with "N/A" or restated content from elsewhere. Only Description, Acceptance Criteria, and Definition of Done are unconditional. Exception: if a section is empty because the answer is *unknown* rather than *not applicable*, keep it and name the gap — that's a Definition of Ready failure, not an omission.

**Be brief.** Short sentences, bullets over paragraphs. Every line should tell a reader something they can act on. Length is not thoroughness; a tight ticket gets read, a bloated one gets skimmed.

---

## Background

(Why this exists — history, prior decisions, research the team needs. Cite the sources you actually used. Omit if the Description is self-explanatory.)

## User Story

(One sentence: "As a [user], I want [goal] so that [benefit]." For internal work, the user is the internal consumer — a developer, operator, downstream service.)

## Description

(The problem being solved or outcome requested. **No implementation detail** — that goes in Technical Notes.)

## Scope

**In Scope:**

- (What this delivers.)

**Out of Scope:**

- (What a reader would reasonably assume is included but isn't. Specific exclusions only — vague ones prevent nothing.)

## Current vs. Expected Behavior

(Only when modifying or replacing existing functionality — migrations, integrations. Omit for net-new.)

**Current Behavior:**

- (Verify against the code and cite `path/to/file.rb:42`. Never describe current behavior from assumption.)

**Expected Behavior:**

- (After this work.)

## Non-Functional Requirements / Constraints

(Constraints that aren't testable pass/fail — performance, security, compliance, data handling, accessibility. Functional requirements go in Acceptance Criteria; don't state either twice.)

## Acceptance Criteria

(Group by category — pick what applies: Status Behavior, Error Handling, Edge Cases, Data Integrity, Loading/Empty States, Audit & Logging, Permissions & Visibility, UI/Modal Behavior.

Cover Error Handling, Loading/Empty States, and Edge Cases wherever the work can hit them — a happy-path-only ticket isn't ready. Skip a category only when it genuinely can't occur.

Each criterion: one observable pass/fail statement someone else can verify without asking what you meant.)

**[Category]**

- [ ] (Criterion.)

## Definition of Done

(Copy verbatim. Do not edit, trim, or reorder.)

- [ ] All Acceptance Criteria have been met
- [ ] Code has been peer reviewed and approved
- [ ] Unit and/or integration tests have been written and are passing
- [ ] QA has verified the work in a staging/test environment (when applicable)
- [ ] No critical or high severity bugs remain open against this ticket
- [ ] Documentation has been updated (if applicable: API docs, internal wikis, runbooks)
- [ ] Product Owner or requestor has reviewed and accepted the work
- [ ] Changes have been merged to the appropriate branch and are ready for release

## Technical Notes

(To be completed by the development team.

The code-grounded approach: files, classes, endpoints, existing patterns to follow, cited as `path/to/file.rb:42`. Verified facts over plausible guesses — if the repo isn't checked out, say so and stay higher-level rather than inventing mechanism; mark anything unverified as such.

Include real risks and assumptions: unknowns, unverified third-party behavior, provisional contracts.)

## Estimation

(Engineering hours: **2 / 4 / 8 / 16 / 32** — no other values; Linear snaps invalid ones to the nearest bucket. Actual dev hours to implement and test, not relative effort. Above 32 means the ticket is too big — split it.)

## Supporting Assets

(List only the sub-items that exist; omit the section if none.)

- **Figma / UI Designs:**
- **Prototype:**
- **External Documentation:**
- **API / Technical Specs:**

## Open Questions / Dependencies

(Unknowns the code can't settle, product decisions, external teams, blocking work. Anything here that blocks the work also fails the Definition of Ready — say so instead of presenting the ticket as Ready.)

## Related Tickets

(Related, blocking, or blocked-by tickets.)

## QA Notes

(How this gets verified: environments, key scenarios, test data or accounts needed, edge cases worth exercising by hand.)

## Additional Resources

(Dashboards, runbooks, logs, incident reports, threads. Omit unless genuinely useful.)
