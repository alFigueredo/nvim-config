-- Linting

vim.pack.add { 'https://github.com/mfussenegger/nvim-lint' }

local lint = require 'lint'
lint.linters_by_ft = {
  -- markdown = { 'markdownlint' }, -- Make sure to install `markdownlint` via mason / npm
  -- c = { 'cpplint' },
  -- cpp = { 'cpplint' },
  -- cmake = { 'cmakelint' },
}

-- To allow other plugins to add linters to require('lint').linters_by_ft,
-- instead set linters_by_ft like this:
-- lint.linters_by_ft = lint.linters_by_ft or {}
-- lint.linters_by_ft['markdown'] = { 'markdownlint' }
--
-- However, note that this will enable a set of default linters,
-- which will cause errors unless these tools are available:
-- {
--   clojure = { "clj-kondo" },
--   dockerfile = { "hadolint" },
--   inko = { "inko" },
--   janet = { "janet" },
--   json = { "jsonlint" },
--   markdown = { "vale" },
--   rst = { "vale" },
--   ruby = { "ruby" },
--   terraform = { "tflint" },
--   text = { "vale" }
-- }
--
-- You can disable the default linters by setting their filetypes to nil:
-- lint.linters_by_ft['clojure'] = nil
-- lint.linters_by_ft['dockerfile'] = nil
-- lint.linters_by_ft['inko'] = nil
-- lint.linters_by_ft['janet'] = nil
-- lint.linters_by_ft['json'] = nil
-- lint.linters_by_ft['markdown'] = nil
-- lint.linters_by_ft['rst'] = nil
-- lint.linters_by_ft['ruby'] = nil
-- lint.linters_by_ft['terraform'] = nil
-- lint.linters_by_ft['text'] = nil

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

-- Create autocommand which carries out the actual linting
-- on the specified events.
local lint_augroup = vim.api.nvim_create_augroup('lint', { clear = true })
vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWritePost', 'InsertLeave' }, {
  group = lint_augroup,
  callback = function()
    -- Only run the linter in buffers that you can modify in order to
    -- avoid superfluous noise, notably within the handy LSP pop-ups that
    -- describe the hovered symbol using Markdown.
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
