-- Linting

vim.pack.add { 'https://github.com/mfussenegger/nvim-lint' }

local lint = require 'lint'
-- Empty: the linters are run explicitly from the autocommand below
lint.linters_by_ft = {}

-- ESLint is not in linters_by_ft because it only runs in projects that configure it:
-- without a config file eslint_d reports an error on every buffer
local eslint_filetypes = { javascript = true, javascriptreact = true, typescript = true, typescriptreact = true }
local eslint_configs = {
  'eslint.config.js',
  'eslint.config.mjs',
  'eslint.config.cjs',
  'eslint.config.ts',
  'eslint.config.mts',
  'eslint.config.cts',
  -- Legacy format, still used by projects on ESLint 8
  '.eslintrc',
  '.eslintrc.js',
  '.eslintrc.cjs',
  '.eslintrc.json',
  '.eslintrc.yml',
  '.eslintrc.yaml',
}

-- Same for Checkstyle: it only runs with the project's own rules. nvim-lint's default is the bundled
-- Google style, which flags nearly every line of code that isn't written in it (tabs, 4 spaces, no Javadoc)
local checkstyle_configs = { 'checkstyle.xml', 'config/checkstyle/checkstyle.xml' }

local lint_augroup = vim.api.nvim_create_augroup('lint', { clear = true })
vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWritePost', 'InsertLeave' }, {
  group = lint_augroup,
  callback = function()
    -- Skip buffers that can't be modified, notably the LSP hover pop-ups
    if vim.bo.modifiable then
      lint.try_lint()
      lint.try_lint 'editorconfig-checker'

      -- Run from the directory of the config, so it is also found when Neovim was opened elsewhere (monorepos)
      local eslint_root = eslint_filetypes[vim.bo.filetype] and vim.fs.root(0, eslint_configs)
      if eslint_root then lint.try_lint('eslint_d', { cwd = eslint_root }) end

      if vim.bo.filetype == 'java' then
        local config = vim.fs.find(checkstyle_configs, { upward = true, path = vim.fs.dirname(vim.api.nvim_buf_get_name(0)) })[1]
        if config then
          lint.linters.checkstyle.config_file = config
          lint.try_lint 'checkstyle'
        end
      end
    end
  end,
})
