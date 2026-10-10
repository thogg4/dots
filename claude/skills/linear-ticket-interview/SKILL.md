---
name: linear-ticket-interview
description: Conduct a thorough, question-by-question interview with the user to fully flesh out a new Linear issue to Deseret Book's Engineering Work Intake & Estimation standard, then create it via the Linear MCP. Unlike drafting a ticket from a rough request, this actively walks through every relevant section of the ticket template and keeps asking follow-up questions until nothing is left vague. Use when the user wants to be interviewed or walked through building a Linear ticket — e.g. "interview me for a ticket", "walk me through creating a Linear issue", "let's build this ticket together, ask me what you need", or any request for thorough question-by-question ticket intake rather than a fast draft.
---

# Linear Ticket Interview

Build a Linear issue by actively interviewing the user, section by section, instead of inferring from a short request. Ask real questions, push on vague answers, and don't move past a section until it's either filled in or the user has explicitly said it's not applicable or genuinely unknown.

This produces the same ticket shape and Definition of Ready gate as Deseret Book's other Linear tooling — it differs only in interaction style: interview-first instead of judgment-first.

## Workflow

1. **Orient before drafting.** Get a one- or two-sentence summary of the ask, then resolve team and project with the user using real options — call `list_teams` and `list_projects` rather than asking them to recall exact names.

2. **Interview section by section**, following `references/ticket-template.md` in order and using `references/interview-questions.md` for the specific questions to ask per section. For a conditional section (Current vs. Expected Behavior, Supporting Assets, etc.), ask whether it applies before deciding to omit it — never drop a section silently.

3. **Push on thin answers.** A vague answer ("make it faster", "handle errors") isn't done — ask a concrete follow-up until it's an observable fact or a testable criterion. Acceptance Criteria must each be a pass/fail statement; Technical Notes must be verified or explicitly flagged unverified.

4. **Verify technical claims in the codebase when one is checked out.** After the user describes their technical approach, search the relevant repo for the real mechanism (files, classes, endpoints) and cite `path/to/file:line`. If the code contradicts what the user said, surface the discrepancy rather than silently overriding it. If no relevant repo is available, say so and keep Technical Notes at the level of detail the user gave, marked unverified.

5. **Estimate together.** Ask for the user's own estimate first (2 / 4 / 8 / 16 / 32 engineering hours — no other values; Linear snaps anything else to the nearest bucket). If they're unsure, walk through complexity factors (files/systems touched, new vs. modified behavior, testing surface) to land on a bucket. If the honest number is above 32, say so and propose splitting the ticket.

6. **Draft to the template.** Read `references/ticket-template.md` and follow its headings and order exactly. Omit a section only once the user has confirmed it doesn't apply; keep and flag a section that's empty because the answer is genuinely unknown.

7. **Gate on the Definition of Ready** (below). If anything is unmet, say so plainly — either ask the missing question now, or if the user truly can't answer it, keep the ticket as Requirements/Blocked and list the gaps. Don't present an incomplete ticket as Ready.

8. **Show the full draft and get explicit confirmation** before creating anything in Linear.

9. **Create it.**
   - **Linear MCP available** (expected in this environment): resolve team/project/labels/assignee to real values via `list_teams`, `list_projects`, `list_issue_labels`, `list_users`, then call `save_issue` with `team`, `title`, `description` (the full template body as Markdown), `estimate`, `labels`, and `project`/`assignee` if applicable. Return the created issue's identifier and URL.
   - **No Linear MCP** → output the **Title** on its own line, the full template body as copy-paste-ready Markdown, and a short footer of fields to set by hand (team, project, estimate, labels).

## Ticket template

Read `references/ticket-template.md` before drafting — don't reconstruct it from memory. Section order: Background · User Story · Description · Scope · Current vs. Expected Behavior · Non-Functional Requirements / Constraints · Acceptance Criteria · Definition of Done · Technical Notes · Estimation · Supporting Assets · Open Questions / Dependencies · Related Tickets · QA Notes · Additional Resources. Only Description, Acceptance Criteria, and Definition of Done are unconditional.

## Interview questions

Read `references/interview-questions.md` for the question bank to work through per section — use it instead of improvising generic questions, especially for the Acceptance Criteria categories (Error Handling, Edge Cases, Loading/Empty States, etc.), which are easy to under-ask.

## Definition of Ready

Ready for sprint planning only when: business objective is clear; acceptance criteria documented; required designs/docs attached; engineering questions resolved; technical approach understood; dependencies identified; work broken into implementation-sized tickets; estimated; risks documented. If any are missing, say which and keep the ticket in Requirements/Blocked.

## Notes

- This is Deseret Book's "Engineering Work Intake & Estimation Guide" standard (Development team Linear doc) — the same template used by the `work-intake` plugin's `create-ticket`/`refine-ticket` skills. Product owns *what/why*; Engineering owns *how*, decomposition, and estimation.
- If oversized work surfaces mid-interview (a research spike bundled with implementation, several unrelated deliverables), say so and propose splitting into separate, implementation-sized tickets before drafting.
