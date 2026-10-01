-- debug.lua
--
-- Shows how to use the DAP plugin to debug your code.
--
-- Primarily focused on configuring the debugger for Go, but can
-- be extended to other languages as well. That's why it's called
-- kickstart.nvim and not kitchen-sink.nvim ;)

vim.pack.add {
  'https://github.com/mfussenegger/nvim-dap',
  'https://github.com/rcarriga/nvim-dap-ui',
  'https://github.com/nvim-neotest/nvim-nio',
  'https://github.com/mason-org/mason.nvim',
  'https://github.com/jay-babu/mason-nvim-dap.nvim',
  'https://github.com/theHamsta/nvim-dap-virtual-text',
  -- 'https://github.com/leoluz/nvim-dap-go',
}

-- Basic debugging keymaps, feel free to change to your liking!
vim.keymap.set('n', '<leader>dc', function() require('dap').continue() end, { desc = 'Debug: Start/Continue' })
vim.keymap.set('n', '<leader>di', function() require('dap').step_into() end, { desc = 'Debug: Step Into' })
vim.keymap.set('n', '<leader>do', function() require('dap').step_over() end, { desc = 'Debug: Step Over' })
vim.keymap.set('n', '<leader>dO', function() require('dap').step_out() end, { desc = 'Debug: Step Out' })
vim.keymap.set('n', '<leader>db', function() require('dap').toggle_breakpoint() end, { desc = 'Debug: Toggle Breakpoint' })
vim.keymap.set('n', '<leader>dB', function() require('dap').set_breakpoint(vim.fn.input 'Breakpoint condition: ') end, { desc = 'Debug: Set Breakpoint' })
-- Toggle to see last session result. Without this, you can't see session output in case of unhandled exception.
vim.keymap.set('n', '<leader>dt', function() require('dapui').toggle() end, { desc = 'Debug: See last session result.' })
vim.keymap.set('n', '<leader>dl', function() require('dap').run_last() end, { desc = 'Debug: Run last configuration.' })

local dap = require 'dap'
local dapui = require 'dapui'

require('mason-nvim-dap').setup {
  -- Makes a best effort to setup the various debuggers with
  -- reasonable debug configurations
  automatic_installation = true,

  -- You can provide additional configuration to the handlers,
  -- see mason-nvim-dap README for more information
  handlers = {},

  -- You'll need to check that you have the required things installed
  -- online, please don't ask me how to install them :)
  ensure_installed = {
    -- Update this to ensure that you have the debuggers for the langs you want
    -- 'delve',
    'cppdbg', -- cpptools, for C/C++
    'python', -- debugpy
  },
}

require('nvim-dap-virtual-text').setup()

-- Dap UI setup
-- For more information, see |:help nvim-dap-ui|
---@diagnostic disable-next-line: missing-fields
dapui.setup {
  -- Set icons to characters that are more likely to work in every terminal.
  --    Feel free to remove or use ones that you like more! :)
  --    Don't feel like these are good choices.
  icons = { expanded = '▾', collapsed = '▸', current_frame = '*' },
  ---@diagnostic disable-next-line: missing-fields
  controls = {
    icons = {
      pause = '⏸',
      play = '▶',
      step_into = '⏎',
      step_over = '⏭',
      step_out = '⏮',
      step_back = 'b',
      run_last = '▶▶',
      terminate = '⏹',
      disconnect = '⏏',
    },
  },
}

-- Change breakpoint icons
vim.api.nvim_set_hl(0, 'DapBreak', { fg = '#e51400' })
vim.api.nvim_set_hl(0, 'DapStop', { fg = '#ffcc00' })
local breakpoint_icons = vim.g.have_nerd_font
    and { Breakpoint = '', BreakpointCondition = '', BreakpointRejected = '', LogPoint = '', Stopped = '' }
  or { Breakpoint = '●', BreakpointCondition = '⊜', BreakpointRejected = '⊘', LogPoint = '◆', Stopped = '⭔' }
for type, icon in pairs(breakpoint_icons) do
  local tp = 'Dap' .. type
  local hl = (type == 'Stopped') and 'DapStop' or 'DapBreak'
  vim.fn.sign_define(tp, { text = icon, texthl = hl, numhl = hl })
end

-- Open only when execution pauses (breakpoint, step, exception), so plain runs like jdtls tests don't flash the UI
dap.listeners.after.event_stopped['dapui_config'] = function() dapui.open() end
dap.listeners.before.event_terminated['dapui_config'] = dapui.close
dap.listeners.before.event_exited['dapui_config'] = dapui.close

-- Install golang specific config
-- require('dap-go').setup {
--   delve = {
--     -- On Windows delve must be run attached or it crashes.
--     -- See https://github.com/leoluz/nvim-dap-go/blob/main/README.md#configuring
--     detached = vim.fn.has 'win32' == 0,
--   },
-- }

-- C/C++ through cpptools (cppdbg) + gdb. Single-config CMake generators (Make, Ninja) put the binary in build/
local function cpp_program() return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/build/', 'file') end

local cppdbg = {
  type = 'cppdbg',
  request = 'launch',
  MIMode = 'gdb',
  program = cpp_program,
  cwd = '${workspaceFolder}',
  stopAtEntry = false,
  -- Show STL containers and strings by value instead of their internals
  setupCommands = {
    { text = '-enable-pretty-printing', description = 'Enable pretty printing', ignoreFailures = false },
  },
}

dap.configurations.cpp = {
  vim.tbl_extend('force', cppdbg, { name = 'Launch' }),
  vim.tbl_extend('force', cppdbg, {
    name = 'Launch with arguments',
    args = function() return require('dap.utils').splitstr(vim.fn.input 'Arguments: ') end,
  }),
  vim.tbl_extend('force', cppdbg, { name = 'Attach to gdbserver :1234', miDebuggerServerAddress = 'localhost:1234' }),
}
dap.configurations.c = dap.configurations.cpp
