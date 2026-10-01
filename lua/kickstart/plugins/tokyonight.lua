local utils = require 'kickstart.plugins.utils'

-- [[ Colorscheme ]]
vim.pack.add { utils.gh 'folke/tokyonight.nvim' }
---@diagnostic disable-next-line: missing-fields
require('tokyonight').setup {
  transparent = true,
  styles = {
    comments = { italic = false }, -- Disable italics in comments
    sidebars = 'transparent',
    floats = 'transparent',
  },
}

-- Other styles: 'tokyonight-storm', 'tokyonight-moon' and 'tokyonight-day'
vim.cmd.colorscheme 'tokyonight-night'
