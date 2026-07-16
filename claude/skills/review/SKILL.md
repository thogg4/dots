---
name: review
description: Run the full code review suite after completing a feature or fix. Use when work is complete and ready for review, when the user invokes /review, or when the Development Workflow calls for the review step. Runs specialized review agents in parallel and addresses their feedback.
---

# Review

## Read-only mode (reviewing a PR)

If you're given a PR to review (e.g. a PR URL or number), this is a **read-only review**: do not apply any changes to the code. Run the agents below, synthesize their feedback, and report the findings. Skip the "apply fixes" behavior in the synthesis step — surface every finding to the human instead, ranked by confidence × severity, and let them decide what to act on.

You may also be running as a review agent inside Plannotator, handed a diff to review with your editing tools disabled. Treat that the same as read-only mode: report findings only, and don't attempt to apply fixes.

For all other invocations (reviewing work you just completed locally), apply fixes as described below.

## Agents

Launch all of the agents below simultaneously and wait for all to complete:

1. **Code review** - `@code-reviewer` - Bugs, logic errors, and code quality.
2. **Functionality review** - `@manual-tester` - Verify the changes work as expected.
3. **Architecture review** - `@architecture-strategist` - Architectural soundness.
4. **Silent failure review** - `@silent-failure-hunter` - Silent failures, inadequate error handling, and inappropriate fallback behavior.
5. **Test coverage review** - `@test-coverage-reviewer` - Adequate test coverage.
6. **Test design review** - launch a `general-purpose` subagent that runs the `/test-design-review` skill against the tests we've added or changed.
7. **Documentation review** - `@docs-reviewer` - Accurate and adequate documentation.
8. **Security review** - `@security-reviewer` - Security concerns.

Once all agents complete, synthesize their feedback:

- Rank findings by confidence × severity.
- Apply high-confidence correctness, security, and silent-failure fixes. (In read-only PR mode, don't apply — report these instead.)
- Surface low-confidence or low-severity findings to the human rather than dropping them silently — note them briefly even when you don't act on them.
- Discard only pure style/naming nits and findings you judge to be false positives (and say which you discarded and why).

After making changes, ask for follow-up reviews from specific subagents if it seems appropriate or helpful. (Not applicable in read-only PR mode.)
