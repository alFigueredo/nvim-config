---Because most plugins are hosted on GitHub, you can use the helper
---function to have less repetition in the following sections.

local utils = {}

---@param repo string
---@return string
function utils.gh(repo) return 'https://github.com/' .. repo end

---Indent the current buffer with `width` spaces when it is new or unindented.
---Otherwise keep what guess-indent detected (and .editorconfig, which is applied after the ftplugin)
---@param width integer
function utils.default_indent(width)
  local ok, guess_indent = pcall(require, 'guess-indent')
  if ok and guess_indent.guess_from_buffer(0) then return end
  vim.bo.shiftwidth = width
  vim.bo.softtabstop = width
  vim.bo.expandtab = true
end

---Root of the Python project the buffer belongs to
---@param buf integer?
---@return string
function utils.python_root(buf) return vim.fs.root(buf or 0, { 'pyproject.toml', '.venv', 'venv', 'requirements.txt', '.git' }) or vim.fn.getcwd() end

---Virtualenv of a Python project: the active one, otherwise `.venv` or `venv` at its root.
---Shared by pyright, debugpy and molten so the three of them pick the same interpreter
---@param root string?
---@return string?
function utils.python_venv(root)
  if vim.env.VIRTUAL_ENV then return vim.env.VIRTUAL_ENV end
  if not root then return end
  for _, name in ipairs { '.venv', 'venv' } do
    local dir = vim.fs.joinpath(root, name)
    if vim.uv.fs_stat(vim.fs.joinpath(dir, 'bin', 'python')) then return dir end
  end
end

---Interpreter of that virtualenv, nil when the project has none
---@param root string?
---@return string?
function utils.python_path(root)
  local venv = utils.python_venv(root)
  if venv then return vim.fs.joinpath(venv, 'bin', 'python') end
end

return utils

-- vim: ts=2 sts=2 sw=2 et
