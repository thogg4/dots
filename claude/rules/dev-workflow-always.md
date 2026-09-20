# Always Use the Development Workflow

Every code change, no matter how small — a one-line fix, a rename, a config tweak — must go through the `dev-workflow` skill and its full 10 steps. Do not make ad hoc edits outside of it, even when a change looks trivial.

Invoke `dev-workflow` yourself as soon as a task will touch code, rather than waiting for the user to run `/dev-workflow`. If a step is genuinely not applicable to the change (e.g., no UI to manually test), say so in one sentence and mark it completed per the skill's own instructions — don't skip invoking the skill itself.
