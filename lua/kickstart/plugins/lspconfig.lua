local utils = require 'kickstart.plugins.utils'

-- [[ LSP Configuration ]]

-- Useful status updates for LSP.
vim.pack.add { utils.gh 'j-hui/fidget.nvim' }
require('fidget').setup {}

-- Buffer-local keymaps and autocommands, set when a server attaches
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
  callback = function(event)
    local map = function(keys, func, desc, mode)
      mode = mode or 'n'
      vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
    end

    map('grn', vim.lsp.buf.rename, '[R]e[n]ame')
    map('gra', vim.lsp.buf.code_action, '[G]oto Code [A]ction', { 'n', 'x' })
    -- Declaration, not definition: in C this goes to the header
    map('grD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

    local client = vim.lsp.get_client_by_id(event.data.client_id)

    -- Jump between a C/C++ source file and its header (command defined by nvim-lspconfig's clangd config)
    if client and client.name == 'clangd' then map('grh', '<Cmd>LspClangdSwitchSourceHeader<CR>', 'Switch source/[H]eader') end

    -- Highlight the references of the word under the cursor while it rests there (see `:help CursorHold`)
    if client and client:supports_method('textDocument/documentHighlight', event.buf) then
      local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
      vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
        buffer = event.buf,
        group = highlight_augroup,
        callback = vim.lsp.buf.document_highlight,
      })

      vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
        buffer = event.buf,
        group = highlight_augroup,
        callback = vim.lsp.buf.clear_references,
      })

      vim.api.nvim_create_autocmd('LspDetach', {
        group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
        callback = function(event2)
          vim.lsp.buf.clear_references()
          vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = event2.buf }
        end,
      })
    end

    if client and client:supports_method('textDocument/inlayHint', event.buf) then
      map('<leader>th', function() vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf }) end, '[T]oggle Inlay [H]ints')
    end
  end,
})

-- Language servers to enable. Mason installs them automatically.
--  See `:help lsp-config` for the keys of each entry
---@type table<string, vim.lsp.Config>
local servers = {
  clangd = {
    -- clang-tidy checks as diagnostics (uses the project's .clang-tidy if present), and no automatic #include on completion.
    -- Only errors on stderr: Neovim writes all of it to lsp.log, which otherwise grows by megabytes per session
    cmd = { 'clangd', '--clang-tidy', '--header-insertion=never', '--log=error' },
  },
  pyright = {
    -- Resolve imports against the project's venv (see utils.python_venv) even when it isn't activated.
    -- Without one pythonPath stays nil and pyright falls back to the `python` in PATH
    on_init = function(client) client.settings.python.pythonPath = utils.python_path(client.root_dir) end,
  },
  ruff = {}, -- Lint diagnostics and quick fixes for Python. Also the formatter, see conform.lua
  ts_ls = {}, -- JavaScript and TypeScript. Formatting is done by prettierd, see conform.lua

  bashls = {},
  neocmake = {},
  -- Completion and diagnostics for LaTeX; building and viewing is done by vimtex
  texlab = {
    settings = {
      texlab = {
        -- Typographic checks (missing `~` before \ref, wrong dashes, plain quotes, ...). Silence unwanted ones with a .chktexrc
        chktex = { onOpenAndSave = true, onEdit = false },
      },
    },
  },

  stylua = {}, -- Used to format Lua code

  -- Special Lua Config, as recommended by neovim help docs
  lua_ls = {
    on_init = function(client)
      client.server_capabilities.documentFormattingProvider = false -- Disable formatting (formatting is done by stylua)

      if client.workspace_folders then
        local path = client.workspace_folders[1].name
        if path ~= vim.fn.stdpath 'config' and (vim.uv.fs_stat(path .. '/.luarc.json') or vim.uv.fs_stat(path .. '/.luarc.jsonc')) then return end
      end

      local current_settings = client.config.settings --[[@as lspconfig.settings.lua_ls]]
      client.config.settings.Lua = vim.tbl_deep_extend('force', current_settings.Lua, {
        runtime = {
          version = 'LuaJIT',
          path = { 'lua/?.lua', 'lua/?/init.lua' },
        },
        workspace = {
          checkThirdParty = false,
          -- NOTE: this is a lot slower and will cause issues when working on your own configuration.
          --  See https://github.com/neovim/nvim-lspconfig/issues/3189
          library = vim.api.nvim_get_runtime_file('', true),
        },
      })
    end,
    ---@type lspconfig.settings.lua_ls
    settings = {
      Lua = {
        format = { enable = false }, -- Disable formatting (formatting is done by stylua)
      },
    },
  },
}

vim.pack.add {
  utils.gh 'neovim/nvim-lspconfig',
  utils.gh 'mason-org/mason.nvim',
  utils.gh 'mason-org/mason-lspconfig.nvim',
  utils.gh 'WhoIsSethDaniel/mason-tool-installer.nvim',
}

-- Automatically install LSPs and related tools to stdpath for Neovim
require('mason').setup {}

-- Translates between nvim-lspconfig server names and mason.nvim package names (e.g. lua_ls <-> lua-language-server)
require('mason-lspconfig').setup {
  automatic_enable = false, -- Change this to true if you want to automatically enable servers that are installed manually (e.g. via :Mason / :MasonInstall)
}

-- Ensure the servers above and the tools below are installed. `:Mason` shows their status
local ensure_installed = vim.tbl_keys(servers or {})
vim.list_extend(ensure_installed, {
  'jdtls', -- started by nvim-jdtls, see nvim-jdtls.lua
  'java-debug-adapter',
  'java-test',

  -- Formatters, see conform.lua
  'clang-format',
  'gersemi',
  'prettierd',
  'shfmt',
  'kulala-fmt',
  'google-java-format',

  -- Linters, see lint.lua
  'checkstyle',
  'editorconfig-checker',
  'eslint_d',
  'shellcheck', -- not run by nvim-lint: bashls finds it in PATH and reports its diagnostics
})

require('mason-tool-installer').setup { ensure_installed = ensure_installed }

for name, server in pairs(servers) do
  vim.lsp.config(name, server)
  vim.lsp.enable(name)
end
