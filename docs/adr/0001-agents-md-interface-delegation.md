# AGENTS.md delegates plugin internals to external docs

AGENTS.md is the interface AI agents use to understand this config. During an architecture review, we found its devbox section described plugin internals (sync strategy, caching, LSP injection hooks) that are now the plugin's own responsibility after its migration to `rbelem/devbox.nvim`. We trimmed it to 4 lines: what it does, which file configures it, and a link to the plugin's docs.

The pattern applies to all plugins: AGENTS.md documents *what a plugin does and how this config uses it* — not *how the plugin works internally*. That belongs in the plugin's own documentation.

**Non-obvious implication:** when a plugin is swapped or its API changes, AGENTS.md needs updating. That's fine — it's a short file, and the agent editing it is already in context. The cost of keeping it lean is lower than the cost of stale internal detail misleading future sessions.
