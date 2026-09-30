local utils = require 'kickstart.plugins.utils'

vim.pack.add { utils.gh 'benlubas/molten-nvim' }

vim.g.molten_auto_open_output = false
vim.g.molten_virt_text_output = true
vim.g.molten_output_virt_lines = true
vim.g.molten_output_win_max_height = 20
vim.g.molten_output_show_more = true

-- Molten Keybindings
vim.keymap.set('n', '<leader>mi', ':MoltenInit<CR>', { silent = true, desc = 'Initialize the plugin' })
vim.keymap.set('n', '<leader>me', ':MoltenEvaluateOperator<CR>', { silent = true, desc = 'run operator selection' })
vim.keymap.set('n', '<leader>ml', ':MoltenEvaluateLine<CR>', { silent = true, desc = 'evaluate line' })
vim.keymap.set('n', '<leader>mr', ':MoltenReevaluateCell<CR>', { silent = true, desc = 're-evaluate cell' })
vim.keymap.set('v', '<leader>me', ':<C-u>MoltenEvaluateVisual<CR>gv', { silent = true, desc = 'evaluate visual selection' })
vim.keymap.set('n', '<leader>md', ':MoltenDelete<CR>', { silent = true, desc = 'molten delete cell' })
vim.keymap.set('n', '<leader>mh', ':MoltenHideOutput<CR>', { silent = true, desc = 'hide output' })
vim.keymap.set('n', '<leader>ms', ':noautocmd MoltenEnterOutput<CR>', { silent = true, desc = 'show/enter output' })
vim.keymap.set('n', '<leader>mp', ':MoltenImagePopup<CR>', { silent = true, desc = 'opens the image' })
