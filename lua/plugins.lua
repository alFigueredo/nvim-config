-- Load plugin modules in order.

require 'kickstart.plugins.guess-indent'
require 'kickstart.plugins.gitsigns'
require 'kickstart.plugins.which-key'
require 'kickstart.plugins.todo-comments'
require 'kickstart.plugins.mini'
require 'kickstart.plugins.telescope'
require 'kickstart.plugins.lspconfig'
require 'kickstart.plugins.conform'
require 'kickstart.plugins.blink-cmp'
require 'kickstart.plugins.treesitter'
require 'kickstart.plugins.treesitter-context'
require 'kickstart.plugins.autopairs'
require 'kickstart.plugins.oil'
require 'kickstart.plugins.nvim-ts-autotag'
require 'kickstart.plugins.hardtime'
require 'kickstart.plugins.plantuml-syntax'
require 'kickstart.plugins.resty'
require 'kickstart.plugins.vimtex'
require 'kickstart.plugins.luasnip-latex-snippets'
require 'kickstart.plugins.render-markdown'
require 'kickstart.plugins.tokyonight'
require 'kickstart.plugins.lualine'
require 'kickstart.plugins.debug'
require 'kickstart.plugins.cmake-tools'
require 'kickstart.plugins.lint'
require 'kickstart.plugins.nvim-jdtls'
require 'kickstart.plugins.image'
require 'kickstart.plugins.molten'

-- Optional modules that are in the repository but not loaded.
-- Uncomment any of the lines below to enable them (you will need to restart nvim).
-- require 'kickstart.plugins.indent-line'
-- require 'kickstart.plugins.neo-tree'

-- Loads every file in `lua/custom/plugins/*.lua`, a place for plugins to try out without touching the list above
-- require 'custom.plugins'

-- vim: ts=2 sts=2 sw=2 et
