local utils = require 'kickstart.plugins.utils'

vim.pack.add { utils.gh 'windwp/nvim-ts-autotag' }

require('nvim-ts-autotag').setup()
