return {
  recommended = function()
    return LazyVim.extras.wants({
      ft = { "pl", "pm", "pod", "t", "man", "perl" },
    })
  end,
  {
    "nvim-treesitter/nvim-treesitter",
    opts = { ensure_installed = { "perl" } },
  },
  {
    "mason-org/mason.nvim",
    opts = { ensure_installed = { "perlnavigator" } },
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      setup = {
        perlnavigator = function(_, opts)
          require("lspconfig").perlnavigator.setup({
            root_dir = require("lspconfig.util").root_pattern(".root", ".git"),
            settings = {
              perlnavigator = {
                perlPath = "perl",
                enableWarnings = true,
                perltidyProfile = "",
                perlcriticProfile = "",
                perlcriticEnabled = true,
              },
            },
          })
        end,
      },
    },
  },
  {
    "mfussenegger/nvim-dap",
    optional = true,
    dependencies = {
      {
        "mason-org/mason.nvim",
        opts = { ensure_installed = { "perl-debug-adapter" } },
      },
    },
    opts = function()
      require("dap").adapters.perlsp = {
        type = "server",
        host = "127.0.0.1",
        port = "27011",
      }

      require("dap").configurations.perl = {
        {
          name = "Launch Perl",
          type = "perlsp",
          request = "launch",
          program = "${workspaceFolder}/${relativeFile}",
          reloadModules = true,
          stopOnEntry = false,
          cwd = "${workspaceFolder}",
        },
      }
    end,
  },
}
