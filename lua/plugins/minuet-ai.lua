return {
  {
    "milanglacier/minuet-ai.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      {
        "Saghen/blink.cmp",
        opts = {
          sources = {
            -- Enable minuet for autocomplete
            default = { 'minuet' },
            -- For manual completion only, remove 'minuet' from default
            providers = {
              minuet = {
                name = 'minuet',
                module = 'minuet.blink',
                score_offset = 8, -- Gives minuet higher priority among suggestions
              },
            },
          },
        },
      },
    },
    event = "BufReadPre",
    opts = {
      provider = "gemini",
      notify = "debug",
    },
  }
}
