local utils = require 'kickstart.plugins.utils'

-- Configure, build, run and debug CMake projects without leaving Neovim.
-- nvim-dap has to be available before setup, otherwise :CMakeDebug is not created
vim.pack.add {
  utils.gh 'nvim-lua/plenary.nvim',
  utils.gh 'mfussenegger/nvim-dap',
  utils.gh 'Civitasv/cmake-tools.nvim',
}

local cmake = require 'cmake-tools'
cmake.setup {
  -- Replaced by the autocmd below
  cmake_regenerate_on_save = false,
  -- A single build/ for every build type: it is where clangd looks for compile_commands.json
  -- and where the manual debug configurations (debug.lua) start looking for the executable
  cmake_build_directory = 'build',
  cmake_compile_commands_options = { action = 'none' },
  -- Same adapter and settings as the manual configurations in debug.lua. The program, its arguments and cwd come from the launch target
  cmake_dap_configuration = {
    type = 'cppdbg',
    request = 'launch',
    MIMode = 'gdb',
    stopAtEntry = false,
    setupCommands = {
      { text = '-enable-pretty-printing', description = 'Enable pretty printing', ignoreFailures = false },
    },
  },
}

-- Regenerate when a CMake file of the project is saved with changes.
-- The plugin's own autocmd calls :CMakeGenerate inside BufWritePost: when it has to ask for a preset, Neovim gives
-- the focus back to the saved window as soon as the autocmd ends and the picker is left open but unreachable.
-- Scheduling it opens the picker once the write has finished
local regenerate_group = vim.api.nvim_create_augroup('cmake-regenerate-on-save', { clear = true })
vim.api.nvim_create_autocmd('BufWritePre', {
  group = regenerate_group,
  pattern = { 'CMakeLists.txt', '*.cmake', 'CMakePresets.json', 'CMakeUserPresets.json' },
  callback = function(event)
    if not vim.bo[event.buf].modified or not cmake.is_cmake_project() then return end
    if not vim.startswith(event.match, vim.fn.getcwd() .. '/') then return end
    vim.api.nvim_create_autocmd('BufWritePost', {
      group = regenerate_group,
      buffer = event.buf,
      once = true,
      callback = function()
        vim.schedule(function()
          cmake.generate({ bang = false, fargs = {} }, nil)
          cmake.get_config():update_targets()
        end)
      end,
    })
  end,
})

vim.keymap.set('n', '<leader>cg', '<Cmd>CMakeGenerate<CR>', { desc = '[C]Make: [G]enerate' })
vim.keymap.set('n', '<leader>cb', '<Cmd>CMakeBuild<CR>', { desc = '[C]Make: [B]uild' })
vim.keymap.set('n', '<leader>cr', '<Cmd>CMakeRun<CR>', { desc = '[C]Make: [R]un' })
vim.keymap.set('n', '<leader>cd', '<Cmd>CMakeDebug<CR>', { desc = '[C]Make: [D]ebug' })
vim.keymap.set('n', '<leader>ct', '<Cmd>CMakeSelectBuildType<CR>', { desc = '[C]Make: Select build [T]ype' })
vim.keymap.set('n', '<leader>cl', '<Cmd>CMakeSelectLaunchTarget<CR>', { desc = '[C]Make: Select [L]aunch target' })
vim.keymap.set('n', '<leader>ca', '<Cmd>CMakeLaunchArgs<CR>', { desc = '[C]Make: Launch [A]rguments' })
vim.keymap.set('n', '<leader>cs', '<Cmd>CMakeStopExecutor<CR><Cmd>CMakeStopRunner<CR>', { desc = '[C]Make: [S]top' })
