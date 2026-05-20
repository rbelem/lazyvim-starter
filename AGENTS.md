# AGENTS.md — Neovim Config

## Architecture

LazyVim-based config. `init.lua` bootstraps lazy.nvim, which loads everything.

```
init.lua → lua/config/lazy.lua
                    ├── LazyVim/LazyVim          (framework defaults)
                    ├── lazyvim.plugins.extras.*  (via lazyvim.json extras)
                    └── import "plugins"          → lua/plugins/*.lua (auto)
```

## Key files & ownership

| Path | Purpose |
|---|---|
| `lua/config/options.lua` | User overrides for Neovim options |
| `lua/config/keymaps.lua` | User keymaps (terminal, etc.) |
| `lua/config/autocmds.lua` | User autocmds |
| `lua/plugins/*.lua` | Plugin specs — each file is a lazy.nvim spec |
| `lua/devbox/` | Local plugin (dir-based, no external source) |
| `lazyvim.json` | Enabled LazyVim extras |
| `stylua.toml` | Formatter: 2-space indent, 120 col width |

## Plugin spec patterns

- Every file in `lua/plugins/` returns a lazy.nvim spec (table or `{...}`).
- `if true then return {} end` at the top **disables** the plugin (example.lua, codecompanion.lua, minuet-ai.lua).
- Local plugins use `dir = "/absolute/path"` (e.g., devbox).
- Override LazyVim's defaults by creating a spec with the same plugin name and `opts =` (lazy.nvim merges).
- The `example.lua` file is a reference: it is guarded and shows all override patterns.

## Devbox plugin (`lua/devbox/`)

- Local plugin: `"devbox-nvim"`, `dir = "/home/rodrigob/.config/nvim/lua/devbox"`.
- Detects `devbox.json` in project roots, runs `devbox shellenv`, injects env vars into `vim.env`.
- Sync by default (blocks until env ready) — essential for LSP (jdtls needs `mvn` on PATH).
- Async optional via `opts = { strategy = "async" }`.
- Caches env per project for the session (cold ~250ms, cached ~0.4ms).
- Commands: `:DevboxActivate`, `:DevboxDeactivate`, `:DevboxStatus`, `:DevboxClearCache`.
- LSP injection hook: on LspAttach, prepends devbox PATH to `client.config.cmd_env`.

## OpenCode config (`lua/plugins/extras/ai/opencode.lua`)

Keymaps (leader prefix `o`):

| Mapping | Action |
|---|---|
| `<leader>oaa` | ask(@this) |
| `<leader>os` | select action |
| `<leader>oo` | toggle |
| `go` / `goo` | operator mode |
| `<leader>op*` | prompts (diagnostics, diff, document, explain, fix, implement, optimize, review, test) |
| `<leader>on` / `<leader>ol` | session new / list |
| `<S-C-u>` / `<S-C-d>` | scroll session |

## Notable overrides

- `vim.g.autoformat = false` — LazyVim auto-format disabled.
- `vim.o.conceallevel = 0` — no hidden markdown links.
- Colorscheme: **kanagawa** (tokyonight and catppuccin disabled).
- Lualine: pipe separators (`|`), no section separators.
- Noice cmdline popup centered at 50%.
- Blink.cmp with minuet-ai provider (gemini) for AI completions (currently disabled via guard).
- CodeCompanion with gemini adapter (currently disabled via guard).

## No CI / No tests / No pre-commit

This is a personal config. No test framework, no CI, no pre-commit hooks. Validate Lua syntax with `luac -p` if available.

## Formatting

- `stylua` expected for Lua formatting (2 spaces, 120 col).
