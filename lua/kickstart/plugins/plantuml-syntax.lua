local utils = require 'kickstart.plugins.utils'

vim.pack.add { utils.gh 'aklt/plantuml-syntax' }

-- PlantUML Renderer Command
local function render_plantuml()
  local file = vim.fn.expand '%:p'

  vim.fn.jobstart({ 'plantuml', file }, {
    stdout_buffered = true,

    on_stdout = function(_, data)
      if data and #data > 0 then vim.notify(table.concat(data, '\n')) end
    end,

    on_stderr = function(_, data)
      if data and #data > 0 then vim.notify(table.concat(data, '\n'), vim.log.levels.ERROR) end
    end,

    on_exit = function(_, code)
      if code == 0 then
        vim.notify '✔ Diagrama generado'

        local png = file:gsub('%.puml$', '.png')
        vim.fn.jobstart({ 'xdg-open', png }, { detach = true })
      else
        vim.notify('❌ Falló la compilación', vim.log.levels.ERROR)
      end
    end,
  })
end

vim.api.nvim_create_user_command('RenderUML', render_plantuml, {})

vim.api.nvim_create_autocmd('FileType', {
  pattern = 'plantuml',
  callback = function(args)
    vim.keymap.set('n', '<leader>pr', render_plantuml, {
      buffer = args.buf,
      desc = 'Render PlantUML',
    })

    vim.api.nvim_create_autocmd('BufWritePost', {
      buffer = args.buf,
      callback = function()
        local file = vim.fn.expand '%:p'
        local output = file:gsub('%.puml$', '.png')

        vim.fn.jobstart({ 'plantuml', file }, {
          on_exit = function(_, code)
            if code == 0 then
              vim.notify('✔ UML generado: ' .. output, vim.log.levels.INFO, { title = 'PlantUML' })
            else
              vim.notify('❌ Error al compilar PlantUML', vim.log.levels.ERROR, { title = 'PlantUML' })
            end
          end,
        })
      end,
    })
  end,
})
