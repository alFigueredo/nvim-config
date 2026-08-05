---Because most plugins are hosted on GitHub, you can use the helper
---function to have less repetition in the following sections.

local utils = {}

---@param repo string
---@return string
function utils.gh(repo) return 'https://github.com/' .. repo end

return utils

-- vim: ts=2 sts=2 sw=2 et
