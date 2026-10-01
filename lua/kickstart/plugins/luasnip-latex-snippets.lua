local utils = require 'kickstart.plugins.utils'

-- Gilles Castel's math snippets: they expand on their own while typing inside a math zone (`//` -> \frac{}{}, `x2` -> x_{2}, `sr` -> ^2).
-- Depends on LuaSnip with autosnippets enabled (blink-cmp.lua) and on vimtex to tell math zones from text
vim.pack.add { utils.gh 'iurimateus/luasnip-latex-snippets.nvim' }

require('luasnip-latex-snippets').setup {
  -- In Markdown the math zones are detected with the treesitter latex parser, which is not installed (see treesitter.lua)
  allow_on_markdown = false,
}
