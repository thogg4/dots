# Planning and Building

## Before You Build

1. **Learn first** - Study the codebase before implementing. Search for similar functionality to understand how problems are typically solved in this project.
2. **Verify approach** - Search for relevant code to confirm your approach matches existing patterns. Don't assume—verify with existing code.
3. **Consider improvements** - Consider if there's a better solution than what was described.
4. **Be thorough** - Take the time to thoroughly consider and confirm your solution before writing code.
5. **Ask questions early** - During validation and planning, ask as many clarifying questions as needed to fully understand the requirements and the desired solution. Once the plan is settled, the calculus flips: pause mid-build only when the work genuinely requires it — a destructive or irreversible action, a real scope change, or input only the user can provide. For minor choices (naming, defaults, which of two equivalent approaches), pick a reasonable option and note it rather than asking.
6. **Look up reference material** - Always read relevant documentation. Use the Context7 MCP Server to look things up. Refer to other materials such as library READMEs, Rails guides, etc. Do this every time you are working with a language, framework, library etc. Never assume that you know the answer as these things change frequently. Your training date is in the past so your knowledge is likely out of date, even if it is a technology you are familiar with.

## Think Before Coding

Don't assume. Don't hide confusion. Surface tradeoffs.

Before implementing:
- State your assumptions explicitly. If uncertain, ask.
- If multiple interpretations exist, present them - don't pick silently.
- If a simpler approach exists, say so. Push back when warranted.
- If something is unclear, stop. Name what's confusing. Ask.

## Correctness

- It is very important that changes are correct.
- Double check requirements as needed.
- Double check language or framework documentation to verify the accuracy of your solution.
- Don't guess. For example, if I ask you to upgrade the application to Ruby 3.4, don't guess what the latest 3.4.x version is; look it up.

## Simplicity First

Write simple, readable, maintainable code. When in doubt, choose the more obvious approach.

- Don't write speculative code.
- No features beyond what was asked.
- No abstractions for single-use code.
- No "flexibility" or "configurability" that wasn't requested.
- No error handling for impossible scenarios. Trust internal code and framework guarantees; only validate at system boundaries (user input, external APIs).
- Don't use feature flags or backwards-compatibility shims when you can just change the code.
- If you write 200 lines and it could be 50, rewrite it.

Ask yourself: "Would a senior engineer say this is overcomplicated?" If yes, simplify.

## TDD

TDD should lead to more rigor and better results. Always build using red-green-refactor TDD. Invoke the `test-driven-development` skill before writing application code and follow it.
