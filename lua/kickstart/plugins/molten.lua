local utils = require 'kickstart.plugins.utils'

-- Dedicated venv with pynvim, jupyter_client, ... (system Python is externally managed on Arch), see the README for the full list.
-- Must be set before vim.pack.add, since installing molten runs :UpdateRemotePlugins
local python_venv = vim.fs.joinpath(vim.fn.stdpath 'data', 'python-venv', 'bin', 'python')
if vim.uv.fs_stat(python_venv) then vim.g.python3_host_prog = python_venv end

vim.pack.add { utils.gh 'benlubas/molten-nvim' }

vim.g.molten_auto_open_output = false
vim.g.molten_virt_text_output = true
vim.g.molten_output_virt_lines = true
vim.g.molten_output_win_max_height = 20
vim.g.molten_output_show_more = true

-- Start molten with the project's own venv as kernel, so each project only installs what it needs
-- (plus ipykernel). Falls back to the global `python3` kernel when there's no venv.
local function molten_init_project()
  local root = utils.python_root()
  local venv = utils.python_venv(root)
  if not venv then
    vim.cmd 'MoltenInit python3'
    return
  end

  local python = vim.fs.joinpath(venv, 'bin', 'python')
  if vim.system({ python, '-c', 'import ipykernel' }):wait().code ~= 0 then
    vim.notify(
      ('%s has no ipykernel, install it with:\n  %s -m pip install ipykernel\n  (or `uv add --dev ipykernel`)'):format(venv, python),
      vim.log.levels.WARN
    )
    return
  end

  -- Short path hash so two projects with the same folder name don't overwrite each other's kernel
  local project = vim.fs.basename(root)
  local kernel = ('%s-%s'):format(project:gsub('[^%w._-]', '_'), vim.fn.sha256(venv):sub(1, 6))
  local data_home = vim.env.XDG_DATA_HOME or vim.fs.joinpath(vim.env.HOME, '.local', 'share')
  if not vim.uv.fs_stat(vim.fs.joinpath(data_home, 'jupyter', 'kernels', kernel, 'kernel.json')) then
    local res = vim.system({ python, '-m', 'ipykernel', 'install', '--user', '--name', kernel, '--display-name', project .. ' (venv)' }):wait()
    if res.code ~= 0 then
      vim.notify('Failed to register kernel ' .. kernel .. ':\n' .. (res.stderr or ''), vim.log.levels.ERROR)
      return
    end
    vim.notify('Registered Jupyter kernel ' .. kernel)
  end

  vim.cmd('MoltenInit ' .. kernel)
end

-- Molten Keybindings
vim.keymap.set('n', '<leader>mi', molten_init_project, { desc = 'Initialize with the project venv' })
vim.keymap.set('n', '<leader>mI', ':MoltenInit<CR>', { silent = true, desc = 'Initialize choosing the kernel' })
vim.keymap.set('n', '<leader>me', ':MoltenEvaluateOperator<CR>', { silent = true, desc = 'run operator selection' })
vim.keymap.set('n', '<leader>ml', ':MoltenEvaluateLine<CR>', { silent = true, desc = 'evaluate line' })
vim.keymap.set('n', '<leader>mr', ':MoltenReevaluateCell<CR>', { silent = true, desc = 're-evaluate cell' })
vim.keymap.set('v', '<leader>me', ':<C-u>MoltenEvaluateVisual<CR>gv', { silent = true, desc = 'evaluate visual selection' })
vim.keymap.set('n', '<leader>md', ':MoltenDelete<CR>', { silent = true, desc = 'molten delete cell' })
vim.keymap.set('n', '<leader>mh', ':MoltenHideOutput<CR>', { silent = true, desc = 'hide output' })
vim.keymap.set('n', '<leader>ms', ':noautocmd MoltenEnterOutput<CR>', { silent = true, desc = 'show/enter output' })
vim.keymap.set('n', '<leader>mp', ':MoltenImagePopup<CR>', { silent = true, desc = 'opens the image' })
