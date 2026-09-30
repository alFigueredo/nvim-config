local utils = require 'kickstart.plugins.utils'

-- Zathura supports forward/inverse search (SyncTeX). The main variant needs xdotool, which only works on X11
local has_xdotool = vim.fn.executable 'xdotool' == 1 and vim.env.XDG_SESSION_TYPE == 'x11'
vim.g.vimtex_view_method = has_xdotool and 'zathura' or 'zathura_simple'

-- Keep latexmk's auxiliary files (.aux, .log, .fls, ...) in build/ instead of next to the .tex
vim.g.vimtex_compiler_latexmk = { aux_dir = 'build' }

vim.pack.add { utils.gh 'lervag/vimtex' }
