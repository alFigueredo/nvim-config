local utils = require 'kickstart.plugins.utils'

vim.pack.add { utils.gh 'MunifTanjim/nui.nvim' }
vim.pack.add { utils.gh 'm4xshen/hardtime.nvim' }

require('hardtime').setup()
