return {
  {
    "NickvanDyke/opencode.nvim",
    event = "VeryLazy",
    dependencies = {
      -- Recommended for `ask()` and `select()`.
      -- Required for `snacks` provider.
      ---@module 'snacks' <- Loads `snacks.nvim` types for configuration intellisense.
      { "folke/snacks.nvim", opts = { input = {}, picker = {}, terminal = {} } },
    },
    config = function()
      ---@type opencode.Opts
      vim.g.opencode_opts = {
        -- Your configuration, if any — see `lua/opencode/config.lua`, or "goto definition" on the type or field.
      }

      -- Required for `opts.events.reload`.
      vim.o.autoread = true

      vim.keymap.set({ "n", "x" }, "<leader>oaa", function() require("opencode").ask("@this: ", { submit = true }) end, { desc = "Ask opencode…" })
      vim.keymap.set({ "n", "x" }, "<leader>os", function() require("opencode").select() end, { desc = "Select opencode action…" })
      vim.keymap.set({ "n", "t" }, "<leader>oo", function() require("opencode").toggle() end, { desc = "Toggle opencode" })

      -- Recommended operator mappings
      vim.keymap.set({ "n", "x" }, "go", function() return require("opencode").operator("@this ") end, { desc = "Opencode operator (range)", expr = true })
      vim.keymap.set("n", "goo", function() return require("opencode").operator("@this ") .. "_" end, { desc = "Opencode operator (line)", expr = true })

      vim.keymap.set("n", "<leader>opg", function() require("opencode").prompt("diagnostics") end, { desc = "Explain diagnostics" })
      vim.keymap.set("n", "<leader>opd", function() require("opencode").prompt("diff") end, { desc = "Review diff" })
      vim.keymap.set("n", "<leader>opc", function() require("opencode").prompt("document") end, { desc = "Document code" })
      vim.keymap.set("n", "<leader>ope", function() require("opencode").prompt("explain") end, { desc = "Explain code" })
      vim.keymap.set("n", "<leader>opf", function() require("opencode").prompt("fix") end, { desc = "Fix diagnostics" })
      vim.keymap.set("n", "<leader>opi", function() require("opencode").prompt("implement") end, { desc = "Implement code" })
      vim.keymap.set("n", "<leader>opo", function() require("opencode").prompt("optimize") end, { desc = "Optimize code" })
      vim.keymap.set("n", "<leader>opr", function() require("opencode").prompt("review") end, { desc = "Review code" })
      vim.keymap.set("n", "<leader>opt", function() require("opencode").prompt("test") end, { desc = "Generate tests" })

      vim.keymap.set("n", "<leader>oi", function() require("opencode").prompt("@buffer", { append = true }) end, { desc = "Append buffer to prompt" })
      vim.keymap.set("x", "<leader>oi", function() require("opencode").prompt("@visible", { append = true }) end, { desc = "Append visible text to prompt" })
      vim.keymap.set("n", "<leader>oe", function() require("opencode").prompt("Explain @cursor and its context") end, { desc = "Explain cursor context" })

      vim.keymap.set("n", "<leader>on", function() require("opencode").command("session.new") end, { desc = "New session" })
      vim.keymap.set("n", "<leader>ol", function() require("opencode").command("session.list") end, { desc = "List sessions" })

      vim.keymap.set("n", "<S-C-u>", function() require("opencode").command("session.half.page.up") end, { desc = "Scroll opencode up" })
      vim.keymap.set("n", "<S-C-d>", function() require("opencode").command("session.half.page.down") end, { desc = "Scroll opencode down" })
    end,
  }
}
