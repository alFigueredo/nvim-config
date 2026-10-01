-- [[ Build steps for `vim.pack` ]]
--  Plugins are installed with `vim.pack.add` in each module of lua/kickstart/plugins/.
--  Here are the build steps some of them need after being installed or updated.
--  See `:help vim.pack` and the README for how to update them

local function run_build(name, cmd, cwd)
  local result = vim.system(cmd, { cwd = cwd }):wait()
  if result.code ~= 0 then
    local stderr = result.stderr or ''
    local stdout = result.stdout or ''
    local output = stderr ~= '' and stderr or stdout
    if output == '' then output = 'No output from build command.' end
    vim.notify(('Build failed for %s:\n%s'):format(name, output), vim.log.levels.ERROR)
  end
end

-- See `:help vim.pack-events`
vim.api.nvim_create_autocmd('PackChanged', {
  callback = function(ev)
    local name = ev.data.spec.name
    local kind = ev.data.kind
    if kind ~= 'install' and kind ~= 'update' then return end

    if name == 'telescope-fzf-native.nvim' and vim.fn.executable 'make' == 1 then
      run_build(name, { 'make' }, ev.data.path)
      return
    end

    if name == 'LuaSnip' then
      if vim.fn.has 'win32' ~= 1 and vim.fn.executable 'make' == 1 then run_build(name, { 'make', 'install_jsregexp' }, ev.data.path) end
      return
    end

    if name == 'nvim-treesitter' then
      if not ev.data.active then vim.cmd.packadd 'nvim-treesitter' end
      vim.cmd 'TSUpdate'
      return
    end

    -- molten is a Python remote plugin: its commands only exist after regenerating the rplugin manifest
    if name == 'molten-nvim' then
      if not ev.data.active then vim.cmd.packadd 'molten-nvim' end
      local ok, err = pcall(vim.cmd, 'UpdateRemotePlugins')
      if not ok then vim.notify(('UpdateRemotePlugins failed for %s:\n%s'):format(name, err), vim.log.levels.ERROR) end
      return
    end
  end,
})

-- vim: ts=2 sts=2 sw=2 et
