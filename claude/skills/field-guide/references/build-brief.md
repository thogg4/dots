# Build brief

The spec for the guide. `<Topic>`, `<Company>`, `<Unit>` and similar come from the interview.

## Contents
- Research
- Chapters
- Make it fun
- Voice
- Brand and format
- Build
- Verification

## Research

- Docs and procedures: read the SOPs, runbooks, training material and vendor docs end to end. Note the document and section for every step you use. When a doc and the system disagree, trust the system and list the mismatch in "Not verified here".
- The system itself: when there's a training, demo or staging environment, walk the core tasks yourself and capture screenshots on safe data.
- Repo (when there is one): clone it with `gh repo clone` and record the current commit SHA. Pin every GitHub code link to that SHA (`https://github.com/<owner>/<repo>/blob/<sha>/<path>#L<n>`) so line numbers don't drift. Read the code, not just the README.
- Every claim must trace back to a file, doc, PR, ticket or message. If you can't verify something, leave it out or label it "a suggestion, not a team decision".
- Linear: scope, status, milestones, rollout dates, project leads, open and unassigned tickets.
- GitHub PRs: find the PRs that built the key screens and features (`git log` on key files, `gh pr list --search`, `gh pr view`). Pull screenshots from their descriptions, and authors and reviewers for the people chapter.
- Slack or Teams: the directory for titles, and the chosen channels for context, announcements and recurring questions (good FAQ and quiz material). Read only; never post.
- Pick people from evidence: project leads, process owners, trainers, authors and reviewers of the key code or docs, and directory titles. For each person, record their role, why they matter here (with the evidence), and what to ask them about. Use they/them unless someone's pronouns are stated.
- Screenshots only from PRs, training or demo environments, or seeded data, and example records only from schema files or synthetic fixtures. Follow the interview's data rules. Never include secrets.
- Gather numbers for hero stats where they're verifiable: for a codebase, things like repo age, commits and contributors; for a process, things like steps, screens, teams involved or the rollout date.

## Chapters

Open with a hero, then about ten to thirteen numbered chapters. Use the **core** chapters in every guide and add the **modules** that fit the purpose and audience. Rename everything to fit the topic and alternate light, tinted and dark sections. A non-technical audience gets no code chapters.

### Core (every guide)

1. **Hero:** a small kicker naming the purpose ("Onboarding field guide", "Training field guide", "What's changing"), a big gradient headline ("Welcome to <Topic>."), a one-paragraph promise, CTAs ("Start the tour", a skip-ahead link, "Where do I get help?"), a row of verifiable stats, a meta line (build date, sources, and repo@sha if there is one), a scroll cue, and a corner brand-mark accent.
2. **Context in 60 seconds:** three cards with the three ideas that make everything else make sense, approved proof points or reasons, and a big pull quote from a real source. Onboarding: "<Company> in 60 seconds". Training: "Why <System> exists". Change rollout: "Why we're changing".
3. **The big picture:** an interactive diagram showing where the topic fits: the system architecture, the process map across teams, or the tools involved.
4. **So what is <Topic>?** Who does what in plain language, with a two-column "who owns which step" view, the one key concept that unlocks the rest, and a timeline of how we got here (or, for a rollout, when things change).
5. **Follow one <Unit>:** a step-through journey diagram with numbered stops. It responds to a Next button, Back, Autoplay, clicking a number, and the arrow keys. Each stop's card explains what happens and who does it, flags a gotcha, and links to its source (the code, the SOP section, or the screen).
6. **Collectible catalog** of the topic's key things (events, statuses, screens, forms, exception types, endpoints, roles). Filter chips by stage, cards that open a dialog with when you'll meet it and what to do about it, a real example from a safe source, and a "caught N of M" counter. Optionally one hidden "secret" card for something real but surprising.
7. **Screens you will see:** a screenshot gallery in browser-frame cards with a lightbox (prev/next, captions, source).
8. **Try it yourself:** hands-on practice. For commands, an animated terminal that walks the runbook steps with copy buttons. For a UI process, a procedure player with the same layout: a step list next to a screenshot and an instruction panel. Follow it with a row of common-mistake cards ("If you see X, do Y").
9. **People and help:** cards with avatars (initials if no photo), role, a hook line, evidence chips, and an expandable "ask them about" list. Lead cards get a gradient border. Then the help channels, office hours or support queue.
10. **Your next steps:** a checklist that remembers progress. Onboarding: setup and first-week tasks. Training: practice tasks and sign-off. Rollout: what to do before, on and after the cutover.
11. **Decoder:** a searchable glossary. Dotted-underlined terms anywhere on the page show a tooltip from the same list.
12. **Boss level:** a ten-question quiz worth 20 XP each, with an explanation per answer and confetti on a pass. Write scenario questions ("A customer brings back X. What do you do first?") over pure recall. Badge shelf below.

### Modules (add when they fit)

- **Old way vs. new way** (change rollout): a side-by-side comparison for each changed task, using the two-column owners layout. Mark what stays the same too.
- **Rollout timeline** (change rollout): dates, cutover, what happens to the old system, and a "now" marker.
- **Code map and feature flags** (technical onboarding or training): the 30 to 40 files that matter, grouped by job in collapsible groups, each with a pinned link, a one-line purpose and a copy button. A flag table showing each flag's local default and what it gates.
- **House rules** (technical onboarding): conventions you'll meet in review, from AGENTS.md, CONTRIBUTING or CI config.
- **Quest board** (onboarding): open unclaimed tickets, with friendly first ones starred as a suggestion, plus in-flight PRs worth reading.
- **Cheat sheet** (training, rollout): a printable one-screen summary of the core tasks with a print stylesheet.
- **FAQ** (training, rollout): real recurring questions from channels and tickets, with answers traced to a source.

Footer: logo, a one-line tagline, a snapshot disclaimer ("trust the system and its owners over this page when they disagree"), the reset button, a sources list, a "Not verified here" list, and fine print (confidentiality label, snapshot date, commit SHA if any, and "a team onboarding resource" or "a team training resource").

Where the data supports it, add a timeline or status chart. Load the `dataviz` skill for any chart, and give each chart a "View as table" disclosure.

## Make it fun

- Award XP for opening each chapter (10), stepping through journey stops, catching cards, checking checklist items, and quiz answers (20 each). Five themed levels; toast on level-up.
- Badges for finishing the journey, catching every card, completing the checklist, and passing the quiz. Some badges grant bonus XP.
- Save progress in `localStorage` under a versioned key (e.g. `<topic>guide:v1`), wrapped in try/catch so the page works with storage off. Include a reset button and an XP dialog listing levels and badges.
- Sticky top bar: brand, chapter-chip nav with scrollspy that keeps the active chip centered, completed chapters marked, a reading-progress bar, and the XP meter.
- Respect `prefers-reduced-motion` for every animation, autoplay, terminal typing and the confetti.

## Voice

Vibrant, warm and a little playful. Keep sentences short. Define jargon on first use (and add it to the glossary). Speak to "you". Never name the person who asked for the guide. For a change rollout, acknowledge that the old way worked and say plainly what gets better. Use em dashes sparingly or not at all (the build fails on any). Label opinions as "a suggestion, not a team decision".

## Brand and format

- Follow the brand skill or assets from the interview: palette, approved pairings, the embedded display font, the logo, and official brand-mark images cropped into section corners. Never draw a substitute.
- Spell the company and product names exactly right everywhere, including alt text and code comments.
- Ship one self-contained HTML file that runs anywhere (see SKILL.md § Output): CSS, JS, images and the font inline, no CDN, fetch, modules or iframes. Aim for under 3 MB so it survives email and LMS upload limits (compress screenshots; prefer WebP or JPEG for photos).
- Make it responsive down to 375 px wide and fully keyboard accessible: real buttons and links, visible focus, dialogs via `<dialog>`, and `aria-live` for toasts and dynamic panels. Every image needs alt text, and text contrast must meet WCAG AA.

## Build

Keep sources in the scratchpad: `index.html` (static chrome and section shells), `styles.css`, `app.js` (all content as data constants at the top, e.g. CHAPTERS, STEPS, CATALOG, SHOTS, PRACTICE, PEOPLE, CHECKS, GLOSSARY, QUIZ, BADGES, LEVELS, plus module data like CODEMAP, FLAGS, CHANGES or FAQ; render functions below), and `assets/`. Reference assets by relative path; `scripts/build.py` inlines them. Rebuild after every change.

## Verification

- Copy the built file alone to a fresh empty folder and open it from there via `file://`, so a missed asset or stray relative path shows up as broken.
- Open the built file in the browser at desktop and 375 px widths. Screenshot every chapter and fix what you see. The console must show zero errors.
- Exercise every interaction: chip nav, journey (buttons, numbers, arrow keys, autoplay), catalog cards and filters, lightbox, practice steps, copy buttons, checklist persistence across reload, glossary search and tooltips, quiz pass and fail, reset.
- Check for these known pitfalls:
  - Text in white cards inside dark sections that inherits a light color and disappears
  - SVG diagrams clipped by their viewBox
  - Chart text that renders tiny (size charts to their container and re-render on resize)
  - Tooltips that linger after a scroll
  - Scroll observers that restart animations or reset progress
  - Nav chips or buttons whose labels wrap
- Spot-check that source links (pinned GitHub links, doc links) resolve.
