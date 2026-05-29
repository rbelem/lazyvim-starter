-- devbox.nvim -- LazyVim plugin spec
--
-- Minimal usage (defaults are enough):
--   { "rbelem/devbox.nvim" }
--
-- Advanced customization:
--   {
--     "rbelem/devbox.nvim",
--     opts = {
--       silent = true,
--       exclude_env = { "^ATUIN_", "^SECRET_" },
--       lsp = { inject_env = false },
--     },
--   }

return {
  "rbelem/devbox.nvim",
  lazy = true,
  event = { "BufReadPre", "BufNewFile" },
  opts = {
    -- "async" (default): never blocks. disk cache makes it instant on repeat.
    -- "sync": blocks until env ready, only useful on cold cache.
    strategy = "async",
    silent = false,
    auto_activate = true,
    devbox_path = "devbox",
    exclude_env = {
      "^ATUIN_",
      "^BLE_",
      "_PREEXEC_",
      "^BASH_",
      "^SHELL",
      "^TERM",
      "^LS_COLORS",
      "^HIST",
      "^PROMPT",
    },
    lsp = {
      inject_env = true,
    },
  },
  config = function(_, opts)
    require("devbox").setup(opts)
  end,
}
