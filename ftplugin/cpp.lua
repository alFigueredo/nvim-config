-- New or unindented files default to clang-format's default (LLVM) style: 2 spaces.
-- Otherwise keep what guess-indent detected (and .editorconfig, which is applied after this)
local ok, guess_indent = pcall(require, 'guess-indent')
if not (ok and guess_indent.guess_from_buffer(0)) then
  vim.bo.shiftwidth = 2
  vim.bo.softtabstop = 2
  vim.bo.expandtab = true
end
