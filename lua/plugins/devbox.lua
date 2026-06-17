-- devbox.nvim -- LazyVim plugin spec
--
-- Minimal usage (defaults are enough):
--   { "rbelem/devbox.nvim" }
--
-- Advanced customization:
--   {
--     "rbelem/devbox.nvim",
--     opts = {
--       notify = "silent",
--       exclude_env = { "^ATUIN_", "^SECRET_" },
--       lsp = { inject_env = false },
--     },
--   }

return {
  "rbelem/devbox.nvim",
  event = { "BufReadPre", "BufNewFile" },
  opts = {
    -- Use progress-style notifications (echom) instead of vim.notify
    notify = "progress",
  },
}
