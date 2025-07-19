return {
  {
    "chentoast/marks.nvim",
    event = "VeryLazy",
    opts = {
      force_write_shada = true,
      mappings = {
        set = "m",
        set_next = "<leader>m,",
        toggle = "<leader>m;",
        next = "<leader>m]",
        prev = "<leader>m[",
        preview = "<leader>m:",
        next_bookmark = "<leader>m}",
        prev_bookmark = "<leader>m{",
        -- delete = "<leader>dm",
        -- delete_line = "<leader>dm-",
        -- delete_bookmark = "<leader>dm=",
        -- delete_buf = "dm<space>"
      },
    },
  },
}
