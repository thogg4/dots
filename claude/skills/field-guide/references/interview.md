# Interview

Ask in this order. **Required** items must be answered (or explicitly marked unknown) before research starts. Offer real options wherever you can look them up.

## 1. Purpose (required)

Ask which kind of guide this is. It sets the defaults for everything below.

- **Onboarding:** people joining a team or project learn how its work fits together and who to ask.
- **Training:** people learn to use a new or unfamiliar system, tool or process.
- **Change rollout:** people who already know the old way learn what's changing, why, and how to work the new way.

Mixed is fine (e.g. onboarding with a training focus). Note which one leads.

## 2. Topic and learning goal (required)

- **Topic:** what system, process, project or domain does this guide teach? (e.g. "the order fulfillment flow", "the new returns process in the POS", "the checkout API project")
- **Audience:** who reads this? (e.g. "engineers joining the Payments team", "store associates", "customer support leads"). Technical or non-technical? This decides whether code chapters belong at all.
- **Baseline:** what do they already know? For a change rollout, that's usually the old way.
- **Gap:** what don't they know yet?
- **Unit of work:** the one thing the reader should follow end to end (an order, a case, a return, a request, a ticket, a document). This drives the journey chapter.
- **Learning goal:** confirm or adjust the default for the purpose:
  - Onboarding: explain what the topic is, follow one unit of work end to end, find what matters (code, docs, screens), try it hands-on, and know who to ask.
  - Training: explain what the system is for, complete the core tasks step by step, recognize the key screens and states, recover from common mistakes, and know where to get help.
  - Change rollout: explain what's changing and why, describe the old way versus the new way, do the new tasks, know the dates and cutover, and know where to get help.
- **Done means:** is there anything the reader must be able to do afterward, like a task, a sign-off or a certification? That feeds the quiz and the next-steps checklist.

## 3. Brand (required)

- **Company or brand name** and its exact spelling (passed to the build script as `--brand`). Product or system names with fixed spelling too.
- **Brand source:** is there a brand skill to load? Otherwise ask for: palette (hex values and which pairings are approved), display font file (it gets embedded), logo file(s), and any brand mark or illustration for corner accents. Never invent brand assets. If there are none, use the neutral defaults in `style-guide.md` and say so.
- **Context chapter:** what framing does the reader need first? For onboarding, usually "<Company> in 60 seconds". For training, "why this system exists". For a change rollout, "why we're changing". Ask for the three ideas that make everything else make sense, and for any approved messaging or announcement to quote from.

## 4. Sources (required: at least one primary source)

Ask which of these exist, and get specifics for each.

- **Docs and procedures:** SOPs, runbooks, training decks, help-center articles, vendor documentation, Notion, Google Drive, Confluence, SharePoint. For training and change rollouts these are often the primary source.
- **The system itself:** a staging, sandbox or training environment you can browse for screenshots? Seeded or demo data?
- **Repo:** `owner/repo` (offer choices with `gh repo list <org>`), plus focus paths, namespaces and docs (runbooks, schemas, OpenAPI specs, ADRs). Only when code matters to the audience or is the best evidence for how the system behaves.
- **Linear:** team and project keys (offer choices with `list_teams` / `list_projects`) for scope, status, owners, milestones, rollout dates and open tickets.
- **Slack or Teams:** channels for context, announcements and FAQs (offer choices). Read only; never post.
- **GitHub PRs:** any known PRs that built key screens or features.
- **People:** anyone the user already knows matters (optional). For training and rollouts, ask about trainers, process owners, super users and the support channel.
- **Style reference:** a previous field guide HTML to match? (Optional. Read it for patterns only.)

Check which connectors and CLIs actually work now. If one is missing, tell the user what that costs (e.g. no Slack means no titles on people cards) and ask whether to continue without it.

## 5. Data rules (required)

- **Sensitive data:** what must never appear? (e.g. personal or customer data, health records, financials). The default rule: screenshots come only from PR descriptions, training or demo environments, or seeded data, and example records come only from schema files or synthetic fixtures. If no safe screenshot exists, skip it; never mock one up.
- **Secrets:** never include secrets, tokens, keys, passwords or credential values, including training-environment logins. Confirm env var or account *names* are OK to show.
- **Confidentiality label** for the footer (e.g. "<Company> internal · Contains no customer data").

## 6. Shape (required: deliverable path)

- **Deliverable path:** where the single file goes, e.g. `~/Downloads/<Topic>_Field_Guide.html`.
- **Chapter plan:** propose the core arc plus the modules that fit the purpose and audience (`build-brief.md` § Chapters), renamed for this topic. Ask which chapters to rename, drop or add. Suggest a catalog name that fits the domain (e.g. "The webhook zoo" for events, "Status menagerie" for order states, "Screen bestiary" for a UI).
- **Hands-on practice:** how should the reader try it? Commands in a terminal (local and/or staging), clicks in a training environment, or a simulated walkthrough of the procedure? Is there an existing runbook or SOP to follow?
- **Dates:** for a change rollout, the timeline, cutover date and what happens to the old way.
- **XP level names:** suggest five themed ranks, from novice to expert, that fit the domain (e.g. "Box Folder" up to "Fulfillment Captain" for a warehouse process). Let the user pick or edit them.
- **Size limit:** default under 3 MB.

## Pushing on vague answers

- "Engineers" or "staff" → which team or role, what do they already use day to day?
- "The whole system" → narrow to the part the reader can finish in one sitting; the rest goes in the big-picture chapter.
- "Everything changes" → list the three to five tasks that change most, and which stay the same.
- "Everyone on the team" for people → you'll pick from evidence; ask only for people the evidence might miss (PMs, trainers, ops, partner contacts).
