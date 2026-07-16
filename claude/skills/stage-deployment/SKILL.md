---
name: stage-deployment
description: Deploy a finished feature branch to the stage environment — merge into stage, run checks, confirm with the user, push, and hand off to /watch-deploy. Use for the stage-deploy step of the Development Workflow or whenever the user asks to deploy work to stage.
---

# Stage Deployment

## Overview

Once you're confident your work is complete, deploy the feature branch to stage so the user can test.

## Steps

1. **Merge into stage** — Merge the feature branch into the `stage` branch.
2. **Run checks** — Run `chp` to confirm CI checks pass on the stage branch.
3. **Confirm with user** — Ask the user if they're ready for you to deploy to stage. Flag any failures from `chp` when you ask.
4. **Push** — Push the `stage` branch to the remote.
5. **Watch, smoke test, report, and monitor** — Run the `/watch-deploy stage` command to handle the rest: streaming deploy progress, smoke testing the site, reporting success, and monitoring Rollbar for new errors.
