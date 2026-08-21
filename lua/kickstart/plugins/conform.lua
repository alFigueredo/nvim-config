local utils = require 'kickstart.plugins.utils'

-- [[ Formatting ]]
vim.pack.add { utils.gh 'stevearc/conform.nvim' }
require('conform').setup {
  notify_on_error = false,
  format_on_save = function(bufnr)
    -- You can specify filetypes to autoformat on save here:
    local enabled_filetypes = {
      lua = true,
      python = true,

      javascript = true,
      javascriptreact = true,
      typescript = true,
      typescriptreact = true,
      html = true,
      css = true,

      json = true,
      yaml = true,
      markdown = true,
      http = true,

      c = true,
      cpp = true,
      cmake = true,

      sh = true,
      bash = true,
      zsh = true,

      java = true,
    }
    if enabled_filetypes[vim.bo[bufnr].filetype] then
      return { timeout_ms = 700 }
    else
      return nil
    end
  end,
  default_format_opts = {
    lsp_format = 'fallback', -- Use external formatters if configured below, otherwise use LSP formatting. Set to `false` to disable LSP formatting entirely.
  },
  -- You can also specify external formatters in here.
  formatters_by_ft = {
    -- rust = { 'rustfmt' },
    -- Conform can also run multiple formatters sequentially
    python = { 'ruff', 'isort', 'black', stop_after_first = true },
    --
    -- You can use 'stop_after_first' to run the first available formatter from the list
    -- js / ts
    javascript = { 'prettierd', 'prettier', stop_after_first = true },
    javascriptreact = { 'prettierd', 'prettier', stop_after_first = true },
    typescript = { 'prettierd', 'prettier', stop_after_first = true },
    typescriptreact = { 'prettierd', 'prettier', stop_after_first = true },
    html = { 'prettierd', 'prettier', stop_after_first = true },
    css = { 'prettierd', 'prettier', stop_after_first = true },

    -- json / yaml / md / http
    json = { 'prettierd', 'prettier', stop_after_first = true },
    yaml = { 'prettierd', 'prettier', stop_after_first = true },
    markdown = { 'prettierd', 'prettier', stop_after_first = true },
    http = { 'kulala-fmt' },

    -- c/c++
    c = { 'clang-format' },
    cpp = { 'clang-format' },
    cmake = { 'gersemi' },

    -- shell
    sh = { 'shfmt' },
    bash = { 'shfmt' },
    zsh = { 'shfmt' },

    java = { 'google-java-format' },
  },
}

vim.keymap.set({ 'n', 'v' }, '<leader>f', function() require('conform').format { async = true } end, { desc = '[F]ormat buffer' })
