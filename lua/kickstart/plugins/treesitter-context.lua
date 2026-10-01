local utils = require 'kickstart.plugins.utils'

-- Keep the enclosing function, class or namespace pinned at the top of the window
vim.pack.add { utils.gh 'nvim-treesitter/nvim-treesitter-context' }

require('treesitter-context').setup {
  max_lines = 4, -- deeply nested code would otherwise eat too much of the window
}

vim.keymap.set('n', '<leader>tc', '<Cmd>TSContext toggle<CR>', { desc = '[T]oggle [C]ontext' })
