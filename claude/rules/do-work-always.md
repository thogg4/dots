# Always Use the Development Workflow

Every code change, no matter how small — a one-line fix, a rename, a config tweak — must go through the `do-work` skill and its full 13 steps. Do not make ad hoc edits outside of it, even when a change looks trivial.

Invoke `do-work` yourself as soon as a task will touch code, rather than waiting for the user to run `/do-work`. If a step is genuinely not applicable to the change (e.g., no UI to manually test), say so in one sentence and mark it completed per the skill's own instructions — don't skip invoking the skill itself.
