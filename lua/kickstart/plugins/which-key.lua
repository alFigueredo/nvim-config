local utils = require 'kickstart.plugins.utils'

-- Useful plugin to show you pending keybinds.
vim.pack.add { utils.gh 'folke/which-key.nvim' }
require('which-key').setup {
  -- Delay between pressing a key and opening which-key (milliseconds)
  delay = 700,
  icons = { mappings = vim.g.have_nerd_font },
  -- Document existing key chains
  spec = {
    { '<leader>s', group = '[S]earch', mode = { 'n', 'v' } },
    { '<leader>t', group = '[T]oggle' },
    { '<leader>h', group = 'Git [H]unk', mode = { 'n', 'v' } }, -- Enable gitsigns recommended keymaps first
    { '<leader>r', group = '[R]est', mode = { 'n', 'v' } },
    { '<leader>l', group = 'Vimtex' },
    { '<leader>d', group = '[D]ebug' },
    { '<leader>p', group = 'Others' },
    { 'gr', group = 'LSP Actions', mode = { 'n' } },
  },
}
