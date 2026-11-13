---
name: field-guide
description: Interview the user, research the real sources behind a system, process or domain (code, docs, SOPs, GitHub PRs, Linear, Slack), and build a single-file, offline, interactive HTML field guide that teaches it. Use for onboarding people onto a team or project, training people on a new or changed system, tool or process, or rolling out a process change. The guide is gamified (XP, badges, boss quiz), brand-styled, and evidence-backed, with a step-through journey, collectible catalog, screens, hands-on practice, people to ask, next steps and a searchable glossary. Use when the user wants an onboarding guide, training guide, field guide, walkthrough, rollout guide, or "get people up to speed on X" resource, or asks to be interviewed to build one.
---

# Field Guide

Build an interactive HTML field guide that teaches one system, process or domain. First interview the user, then research every source, then build, then check it visually. Expect a long run.

The reader is someone who needs to learn the topic: a new team member, a person being trained on a new system or process, or a team going through a change. The guide speaks to "you" the reader and never names the person who asked for it.

## Output: always one self-contained HTML file

The deliverable is always a single `.html` file that runs anywhere: opened by double-click from disk (`file://`), from a shared drive, as an email or chat attachment, on an intranet, or uploaded to an LMS. It needs no server, no install, no login and no network. That means:

- Everything is inline: CSS, JS, images, the font. No CDN, no fetch, no ES modules, no iframes.
- It degrades gracefully in locked-down hosts (sandboxed iframes, private windows): wrap every `localStorage` and clipboard call in try/catch with a fallback, and the page still renders and teaches with both blocked.
- Links out (to GitHub, docs, tickets) are fine as plain links, but the guide never depends on them to render.

This rule overrides other output defaults: don't produce a Doc, a slide deck, an Artifact type, `.docx`, `.pptx` or a PDF instead. If the user asks for one of those, make the HTML file anyway and confirm with them first. Publishing the same HTML file as an Artifact link is fine when the user asks for a link, in addition to the file.

## Workflow

### 1. Interview

Work through `references/interview.md` in order. The first answer, the guide's **purpose** (onboarding, training, or change rollout), shapes everything after it: the audience questions, the sources, and the chapter plan. Ask in small batches. Use AskUserQuestion when there are real options to pick from (e.g. teams and projects from Linear, channels from Slack, repos from `gh`). Look up options instead of making the user recall exact names. Push on vague answers until each is concrete.

Do not start research until every **required** item in the interview is answered or explicitly marked unknown. Then play back a short brief (purpose, topic, audience, learning goal, unit of work, brand, sources, data rules, deliverable path, chapter plan) and get a yes before continuing.

### 2. Research

Follow `references/build-brief.md` § Research. Research all sources before writing any copy. Track every fact with its source (file:line at the pinned SHA, doc and section, PR number, ticket ID, Slack message) so the footer and the final report can cite them. Anything you can't verify gets cut or labeled "a suggestion, not a team decision".

### 3. Build

Read `references/build-brief.md` (chapters, voice, format) and `references/style-guide.md` (visual system, components, interaction patterns) before writing any code. If the user supplied a previous field guide as a style reference, read it too and match it over the style guide where they differ. Read it for patterns, never content.

Work in the scratchpad: `index.html`, `styles.css`, `app.js` (data constants at the top, rendering below), `assets/`. Build the deliverable with the bundled script, and rebuild after every change:

```bash
python3 <skill-dir>/scripts/build.py <src-dir> <deliverable.html> --brand "<Company Name>" [--brand "<Product>"] [--max-mb 3]
```

Keep every image and font under `assets/`. The script inlines local CSS, JS, images and fonts as data URIs, including `'assets/...'` paths inside JS data. It fails, writing nothing, on an em dash, a misspelled brand name, an external resource reference, runtime network or module loading, or output over the size limit. Fix the source and rebuild; never hand-edit the output.

Load the `dataviz` skill before building any chart. Use the brand skill or brand assets named in the interview; never draw a substitute logo or mascot.

### 4. Check

Follow `references/build-brief.md` § Verification: browser screenshots of every chapter at desktop and 375 px widths, zero console errors, the known-pitfalls list, and a spot-check that source links resolve. Iterate until it looks right.

### 5. Report

Tell the user: the deliverable path, what's in the guide (chapter list), the sources used, gaps you couldn't verify, and everything presented as a suggestion rather than a fact. The guide contains internal information, so publish it as an Artifact link only if the user asks; the HTML file is the deliverable either way.
