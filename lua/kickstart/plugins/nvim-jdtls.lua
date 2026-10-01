local utils = require 'kickstart.plugins.utils'

vim.pack.add { utils.gh 'mfussenegger/nvim-jdtls' }

-- jdtls is started by nvim-jdtls (not vim.lsp.enable) so its client-side extensions work:
-- generate constructors/hashCode/equals/toString prompts, organize imports, extract refactors, tests and debug

local mason_share = vim.fs.joinpath(vim.fn.stdpath 'data', 'mason', 'share')

-- glob(..., true, true) returns a list, which is empty if the package isn't installed
local bundles = vim.fn.glob(vim.fs.joinpath(mason_share, 'java-debug-adapter', 'com.microsoft.java.debug.plugin-*.jar'), true, true)

local java_test_bundles = vim.fn.glob(vim.fs.joinpath(mason_share, 'java-test', '*.jar'), true, true)
local excluded = {
  'com.microsoft.java.test.plugin.jar', -- unversioned symlink to the same jar
  'com.microsoft.java.test.runner-jar-with-dependencies.jar',
  'jacocoagent.jar',
}
for _, java_test_jar in ipairs(java_test_bundles) do
  local fname = vim.fn.fnamemodify(java_test_jar, ':t')
  if not vim.tbl_contains(excluded, fname) then table.insert(bundles, java_test_jar) end
end

-- Lombok ships with Mason's jdtls package. Without the agent jdtls doesn't see the generated
-- getters, constructors, builders, ... and reports every use of them as an error
local lombok = vim.fs.joinpath(mason_share, 'jdtls', 'lombok.jar')

local root_markers = { 'gradlew', 'mvnw', 'pom.xml', 'build.gradle', 'build.gradle.kts', 'settings.gradle', 'settings.gradle.kts', '.git' }

vim.api.nvim_create_autocmd('FileType', {
  group = vim.api.nvim_create_augroup('kickstart-jdtls', { clear = true }),
  pattern = 'java',
  callback = function(args)
    local jdtls = require 'jdtls'

    local root_dir = vim.fs.root(args.buf, root_markers) or vim.fn.getcwd()
    -- One workspace per project, otherwise jdtls mixes up their indexes
    local project = vim.fn.fnamemodify(root_dir, ':p:h'):gsub('[/\\:]', '_')
    local workspace_dir = vim.fs.joinpath(vim.fn.stdpath 'cache', 'jdtls', 'workspace', project)

    local cmd = { 'jdtls', '-data', workspace_dir }
    if vim.uv.fs_stat(lombok) then table.insert(cmd, 2, '--jvm-arg=-javaagent:' .. lombok) end

    jdtls.start_or_attach({
      cmd = cmd,
      root_dir = root_dir,
      capabilities = require('blink.cmp').get_lsp_capabilities(),
      init_options = {
        bundles = bundles,
      },
    }, {
      -- Registers the java debug adapter with nvim-dap and the main class configurations
      dap = { hotcodereplace = 'auto' },
    }, { bufnr = args.buf })

    local map = function(keys, func, desc, mode) vim.keymap.set(mode or 'n', keys, func, { buffer = args.buf, desc = 'Java: ' .. desc }) end

    map('<leader>jo', jdtls.organize_imports, '[O]rganize imports')
    map('<leader>jv', jdtls.extract_variable, 'Extract [V]ariable')
    map('<leader>jc', jdtls.extract_constant, 'Extract [C]onstant')
    -- Visual extracts read the '< '> marks, which are only updated after leaving visual mode
    map('<leader>jv', "<Esc><Cmd>lua require('jdtls').extract_variable { visual = true }<CR>", 'Extract [V]ariable', 'x')
    map('<leader>jc', "<Esc><Cmd>lua require('jdtls').extract_constant { visual = true }<CR>", 'Extract [C]onstant', 'x')
    map('<leader>jm', "<Esc><Cmd>lua require('jdtls').extract_method { visual = true }<CR>", 'Extract [M]ethod', 'x')
    map('<leader>jt', jdtls.test_class, '[T]est class')
    map('<leader>jn', jdtls.test_nearest_method, 'Test [N]earest method')
    map('<leader>jp', jdtls.pick_test, '[P]ick test')
    map('<leader>ju', '<Cmd>JdtUpdateConfig<CR>', '[U]pdate project config')
  end,
})
