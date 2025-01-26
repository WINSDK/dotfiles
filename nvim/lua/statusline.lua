local lsp_status = require('lsp-status')

lsp_status.config({
  status_symbol = '',
  current_function = false,
  indicator_errors = 'ERRO',
  indicator_warnings = 'WARN',
  indicator_info = 'INFO',
  indicator_hint = 'HINT',
  indicator_ok = '',
})

lsp_status.register_progress()

function show_lsp_status()
  if #vim.lsp.buf_get_clients() > 0 then
    return lsp_status.status()
  end

  return ""
end

vim.o.statusline = "%{%v:lua.show_lsp_status()%}"

return lsp_status
