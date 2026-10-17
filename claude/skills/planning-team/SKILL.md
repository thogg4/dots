---
name: planning-team
description: Assemble the multi-agent planning team (Codebase Explorer, Best Practices Researcher, Architecture Strategist, Plan Author, Plan Critic) and synthesize their findings into a formal plan. Use for the planning step of the Development Workflow, or whenever the user asks for a formal plan for a feature, bug fix, or refactor.
---

# Planning Team

For the planning step, create the below team. Then synthesize their findings into a formal plan.

## Team Members

Every subagent runs on Opus. Pass the listed `model` when spawning each one — don't let it inherit the session's model.

**Product Owner / Lead Planner** (Tim)
- Set the direction with a high-level plan before any research begins.
- Decide what the feature should do and the rough shape of the approach.
- Final authority on scope, tradeoffs, and whether the plan is ready to build.
- Answers: "What are we building and roughly how?"

**Codebase Explorer** (subagent_type: `Explore`, model: `opus`)
- Deep-dive into existing code relevant to the task
- Map relevant files, trace execution paths, identify existing patterns and conventions
- Identify dependencies, potential conflicts, and constraints
- Render existing flows as Mermaid diagram(s) when helpful (e.g. `flowchart`, `sequenceDiagram`) and return them inline with findings. Skip diagrams only when the task touches no meaningful flow (e.g. a one-line config change).
- Answers: "What do we have today and how does it work?"

**Best Practices Researcher** (subagent_type: `best-practices-researcher`, model: `opus`)
- Use the @best-practices-researcher agent to evaluate best practices for the work being planned.
- Name the sources to consult: consider Context7 MCP, the project's installed-version docs (Gemfile.lock, package.json), repo READMEs and changelogs, and well-regarded open source examples. Cite the version alongside each recommendation.
- Answers: "What's the right way to do this according to docs and community standards?"

**Architecture Strategist** (subagent_type: `architecture-strategist`, model: `opus`)
- Use the @architecture-strategist agent to evaluate appropriate and effective architectural approaches for the work being planned.
- Answers: "What is the best architectural approach and what fits best into our current architecture?"

**Plan Author** (subagent_type: `general-purpose`, model: `opus`)
- Receives the Lead Planner's high-level plan and the full findings from the Codebase Explorer, Best Practices Researcher and Architecture Strategist
- Resolves conflicts between recommendations and writes the formal plan
- Revises the plan in response to the Plan Critic's feedback
- Answers: "Given everything we learned, what exactly is the plan?"

**Plan Critic** (subagent_type: `general-purpose`, model: `opus`)
- Review the proposed plan
- Challenge assumptions, identify gaps or risks, and suggest simpler alternatives
- Look for over-engineering, missing edge cases, and security concerns
- Answers: "What could go wrong, what's missing, and is there a simpler way?"

## Creating the Plan

1. Confirm we're in Plan Mode. If we're not, pause and switch to it or ask the user to switch to it before continuing.
2. Ask the Product Owner / Lead Planner to share their basic plan for the feature before you do any research of your own. The plan should be fairly high-level — not detailed — but it must reflect their own thinking about how to approach the work on a technical level. If they can't articulate a basic plan, ask them to do more research first and come back. Once they share it, restate it briefly to confirm you've understood it, then carry it into the research steps below. During and after research, push back if their plan looks wrong, conflicts with the codebase, or has problems — your job is to challenge it on the merits, not rubber-stamp it.
3. Start the Codebase Explorer, Best Practices Researcher and Architecture Strategist team members.
4. Once all 3 finish their work, start the Plan Author. Give it the Lead Planner's plan and all three sets of findings verbatim — not summarized — including the Codebase Explorer's existing-flow diagrams, along with the instructions in steps 5 and 6. Don't write the plan yourself; the Plan Author resolves any conflicts between recommendations and writes it.
5. The Plan Author creates the plan, carrying the Codebase Explorer's existing-flow diagrams into it so it shows how the system works today. It should consider including diagrams of the proposed design — the new/changed flow, component relationships, or data/sequence of the approach. Default to Mermaid for diffability; reach for HTML only when something interactive is genuinely needed.
6. Verification audit — the Plan Author re-reads the plan before returning it. For every factual claim about current system behavior, either append its evidence citation (`file:line`, doc URL, command output) or prefix the claim with `Unverified:`. For every item in the scope / Files-to-Modify list, add a one-sentence rationale explaining why it belongs. Include an "Out of scope (and why)" section listing anything deliberately excluded and the reason for excluding it. This step exists because abstract rules to "verify" and "justify scope" get skipped during drafting — the audit is a dedicated pass that forces the missing artifacts to become visible.
7. Present the plan to the Plan Critic.
8. Send the Plan Critic's feedback back to the Plan Author — continue the same agent so it keeps its context — to update the plan. Do additional research if needed and pass along what you find.
9. Present the plan to the user for review.
