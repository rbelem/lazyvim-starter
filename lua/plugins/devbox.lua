-- devbox.nvim -- LazyVim plugin spec
--
-- Minimal usage (defaults are enough):
--   { "devbox-nvim", dir = "~/.config/nvim/lua/devbox" }
--
-- Advanced customization:
--   {
--     "devbox-nvim",
--     dir = "~/.config/nvim/lua/devbox",
--     opts = {
--       silent = true,
--       exclude_env = { "^ATUIN_", "^SECRET_" },
--       lsp = { inject_env = false },
--     },
--   }

return {
  "devbox-nvim",
  dir = "/home/rodrigob/.config/nvim/lua/devbox",
  lazy = true,
  event = { "BufReadPre", "BufNewFile" },
  opts = {
    -- "sync" (default): blocks until env is ready, LSP sees correct PATH
    -- "async": non-blocking, LSP may not see devbox PATH on first run
    strategy = "sync",
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
