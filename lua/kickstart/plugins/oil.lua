local utils = require 'kickstart.plugins.utils'

vim.pack.add { utils.gh 'stevearc/oil.nvim' }

require('oil').setup {
  view_options = {
    show_hidden = true,
  },
  delete_to_trash = true,
  watch_for_changes = true,
}
