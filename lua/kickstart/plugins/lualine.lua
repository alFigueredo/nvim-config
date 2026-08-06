local utils = require 'kickstart.plugins.utils'

vim.pack.add { utils.gh 'nvim-tree/nvim-web-devicons' }
vim.pack.add { utils.gh 'nvim-lualine/lualine.nvim' }

require('lualine').setup {
  sections = {
    lualine_c = { 'buffers' },
  },
}
