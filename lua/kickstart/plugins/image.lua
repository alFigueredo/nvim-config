local utils = require 'kickstart.plugins.utils'

vim.pack.add { utils.gh '3rd/image.nvim' }

require('image').setup {
  backend = 'ueberzug', -- or "ueberzug" or "sixel"
  processor = 'magick_cli', -- or "magick_rock"
  integrations = {
    markdown = {
      only_render_image_at_cursor = true, -- defaults to false
      only_render_image_at_cursor_mode = 'popup', -- "popup" or "inline", defaults to "popup"
    },
  },
  max_width = 20, -- tweak to preference
  max_height = 12, -- ^
  max_height_window_percentage = math.huge, -- this is necessary for a good experience
  max_width_window_percentage = math.huge,
  window_overlap_clear_enabled = true,
}
