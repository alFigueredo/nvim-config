local utils = require 'kickstart.plugins.utils'

vim.pack.add { utils.gh '3rd/image.nvim' }

-- ueberzugpp only works on X11 or on these Wayland compositors (not KWin)
local function ueberzug_supported()
  if vim.fn.executable 'ueberzugpp' == 0 then return false end
  if vim.env.XDG_SESSION_TYPE == 'x11' then return true end
  return vim.env.HYPRLAND_INSTANCE_SIGNATURE ~= nil or vim.env.SWAYSOCK ~= nil or vim.env.WAYFIRE_SOCKET ~= nil
end

if not ueberzug_supported() then return end

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

-- Let molten render plots inline too
vim.g.molten_image_provider = 'image.nvim'
