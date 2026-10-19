---
name: planning-team
description: Size the planning work (small / medium / large), run the matching planning team (Codebase Explorer, Architecture Strategist, Best Practices Researcher, Plan Critic), and write a formal plan from their findings. Use for the planning step of the Development Workflow, or whenever the user asks for a formal plan for a feature, bug fix, or refactor.
---

# Planning Team

Size the work, run the team that tier calls for, then write the formal plan yourself from their findings.

## Roles

Pass the listed `model` when spawning each subagent — don't let it inherit the session's model. Give each one exactly the inputs listed and its output cap.

**Product Owner / Lead Planner** (Tim)
- Sets direction with a high-level plan before research shapes the approach. Required at every tier.
- Final authority on scope, tradeoffs, tier, and whether the plan is ready to build.
- Answers: "What are we building and roughly how?"

**Codebase Explorer** (subagent_type: `Explore`, model: `haiku`)
- Input: the task/ticket and its linked documentation. Not Tim's plan — it starts before he replies. It doesn't load CLAUDE.md, so include any project conventions it needs.
- Map relevant files, trace execution paths, identify existing patterns, conventions, dependencies and constraints. Render existing flows as Mermaid (`flowchart`, `sequenceDiagram`) unless the task touches no meaningful flow.
- Cite `file:line` for every claim. Ask for "very thorough" exploration in the prompt (it isn't a tool parameter). Prioritize findings most relevant to the task's requirements.
- Cap: ~400 words plus diagrams.
- Answers: "What do we have today and how does it work?"

**Architecture Strategist** (subagent_type: `architecture-strategist`, model: `opus`)
- Open the prompt with: "Do not map the codebase — the Codebase Explorer's findings below already do. Read files only to verify a specific claim."
- Input: the task/ticket, Tim's plan, and the Explorer's findings verbatim, including diagrams.
- Cap: ~400 words, numbered recommendations.
- Answers: "What is the best approach and what fits our current architecture?"

**Best Practices Researcher** (subagent_type: `best-practices-researcher`, model: `opus`)
- Input: Tim's plan and the task's linked documentation.
- Start from those docs before Context7 or the web.
- Cap: ~300 words.
- Answers: "What's the right way to do this according to docs and community standards?"

**Plan Critic** (subagent_type: `general-purpose`, model: `opus`)
- Input: the task/ticket, Tim's plan, the Explorer's findings, and the written plan.
- Challenge assumptions; find gaps, risks, over-engineering, missing edge cases, security concerns, and simpler alternatives.
- Cap: ~300 words, issues ranked by impact, each marked plan-changing or not.
- Answers: "What could go wrong, what's missing, and is there a simpler way?"

## Tiers

"Fits when" is a first estimate; see step 4. If more than one column fits, use the largest.

| | Small | Medium | Large |
|---|---|---|---|
| Fits when | One area, ~3 files or fewer, follows existing patterns | More files, or a library/API new to the codebase, within the current architecture | Schema/data change, auth or security, new component, or crosses module boundaries |
| Strategist | — | Yes | Yes |
| Researcher | — | Only if a library/API is new to the codebase | Yes |
| Critic | — | Yes | Yes |

## Creating the Plan

Throughout: if an agent fails, returns nothing, or (the Explorer) returns uncited findings, re-run it once before using its output — the Explorer on `opus`. If it still falls short, tell Tim. A retry doesn't count as a second Critic pass.

1. Confirm we're in Plan Mode. If we're not, pause and switch to it or ask Tim to switch to it before continuing.
2. Pick a provisional tier with a one-line reason. In one message, tell Tim the tier (he can override it) and ask for his high-level plan. In the same turn, launch the Codebase Explorer in the background — it's read-only, so it's safe to start before he replies. His plan should be high-level but must reflect his own technical thinking. If he can't articulate one, ask him to research more and come back.
3. Restate Tim's plan briefly to confirm it. If the tier calls for the Researcher, start it now without waiting for his reply. During and after research, push back if his plan looks wrong, conflicts with the codebase, or has problems — challenge it on the merits, don't rubber-stamp it.
4. When the Explorer returns, re-check the tier against the table. If Tim set the tier himself, don't change it — recommend escalating if the findings call for it and let him decide. Otherwise, only escalate on your own, and tell him. His call always wins, in either direction. If he lowers the tier, stop any agent it no longer calls for (TaskStop) and ignore its output.
5. Start every research agent (Strategist, Researcher) the current tier calls for that isn't already running or done.
6. Once the current tier's agents have returned, write the plan yourself. Resolve conflicts between recommendations, and name any you rejected and why. Carry the Explorer's existing-flow diagrams in, and add Mermaid diagrams of the proposed design when they help. Use HTML only when something interactive is genuinely needed. Keep a Small plan short.
7. Verification audit — re-read the plan before showing it. Open the cited `file:line`s that the plan's decisions rest on and confirm them yourself (the Explorer may run on Haiku, so don't trust those unchecked). For every factual claim about current system behavior, either append its evidence (`file:line`, doc URL, command output) or prefix it with `Unverified:`. Give each item in the Files-to-Modify list a one-sentence rationale. Include an "Out of scope (and why)" section.
8. Medium and Large: send the Plan Critic the plan. Revise only for plan-changing issues — ones that change the approach, the files touched, the scope, or the test strategy. Re-apply step 7 to the revised sections. Don't re-run the Critic.
9. Present the plan to Tim. Medium and Large: list each Critic issue as accepted, rejected, or noted (not plan-changing), with a one-line reason. Name any role that didn't deliver.
