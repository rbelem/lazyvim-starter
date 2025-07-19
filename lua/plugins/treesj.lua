return {
  {
    'Wansmer/treesj',
    dependencies = { 'nvim-treesitter/nvim-treesitter' }, -- if you install parsers with `nvim-treesitter`
    cmd = { 'TSJToggle', 'TSJSplit', 'TSJJoin' },
    event = 'VeryLazy',
    keys = { { '<leader>j', '<CMD>TSJToggle<CR>', mode = 'n', silent = true, remap = false, { desc = 'Join Toggle' } } },
    opts = { use_default_keymaps = false },
  }
}
