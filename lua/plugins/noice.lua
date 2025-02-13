return {
  {
    "folke/noice.nvim",
    opts = {
      -- Center the cmdline popup
      presets = {
        command_palette = {
          views = {
            cmdline_popup = {
              position = {
                row = "50%",
                col = "50%",
              },
              size = {
                min_width = 60,
                width = "auto",
                height = "auto",
              },
            },
            cmdline_popupmenu = {
              position = {
                row = "67%",
                col = "50%",
              },
            },
          },
        },
      },
    },
  },
}
