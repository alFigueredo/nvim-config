local utils = require 'kickstart.plugins.utils'

vim.pack.add { utils.gh 'nvim-lua/plenary.nvim' }
vim.pack.add { utils.gh 'lima1909/resty.nvim' }

require('resty').setup {
  output = {
    body_pretty_print = true,
  },
}
