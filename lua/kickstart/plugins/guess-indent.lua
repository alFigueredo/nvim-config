local utils = require 'kickstart.plugins.utils'

-- Detect the indentation of existing files
vim.pack.add { utils.gh 'NMAC427/guess-indent.nvim' }
require('guess-indent').setup {
  -- In files indented with tabs, one indent level is one tab: shiftwidth = 0 follows tabstop.
  -- Without this they would inherit the 2 spaces of the global default (see options.lua)
  on_tab_options = { expandtab = false, shiftwidth = 0, softtabstop = 0 },
}
