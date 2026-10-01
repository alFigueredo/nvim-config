local utils = require 'kickstart.plugins.utils'

-- [[ Snippet Engine ]]
vim.pack.add { { src = utils.gh 'L3MON4D3/LuaSnip', version = vim.version.range '2.*' } }
require('luasnip').setup {
  enable_autosnippets = true, -- needed by the LaTeX math snippets, see luasnip-latex-snippets.lua
}

-- Premade snippets for many languages
vim.pack.add { utils.gh 'rafamadriz/friendly-snippets' }
require('luasnip.loaders.from_vscode').lazy_load()

-- [[ Autocomplete Engine ]]
vim.pack.add { { src = utils.gh 'saghen/blink.cmp', version = vim.version.range '1.*' } }
require('blink.cmp').setup {
  keymap = {
    -- <c-y> accepts, <c-n>/<c-p> select, <c-space> opens the menu or the docs, <c-e> hides the menu,
    -- <c-k> toggles signature help and <tab>/<s-tab> move through the snippet. See `:help blink-cmp-config-keymap`
    preset = 'default',
  },

  appearance = {
    nerd_font_variant = 'mono',
  },

  completion = {
    -- <c-space> shows the documentation; `auto_show = true` would show it after a delay
    documentation = { auto_show = false, auto_show_delay_ms = 500 },
  },

  sources = {
    default = { 'lsp', 'path', 'snippets' },
    -- Prose: also complete words already written in the open buffers
    per_filetype = {
      markdown = { inherit_defaults = true, 'buffer' },
      tex = { inherit_defaults = true, 'buffer' },
    },
  },

  snippets = { preset = 'luasnip' },

  -- 'prefer_rust_with_warning' would use the faster Rust matcher, which downloads a prebuilt binary
  fuzzy = { implementation = 'lua' },

  -- Shows a signature help window while you type arguments for a function
  signature = { enabled = true },
}
