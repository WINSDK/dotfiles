vim.api.nvim_create_user_command("Make", function(opts)
  local cmd = opts.args ~= "" and ("make " .. opts.args) or "make"
  vim.cmd("botright split | resize 15 | terminal " .. cmd)
  vim.cmd("startinsert")
end, { nargs = "*", complete = "shellcmd" })

vim.api.nvim_create_user_command(
  "Format",
  function(...)
    require("conform").format({ async = true, lsp_fallback = true })
  end,
  {}
)

vim.api.nvim_create_user_command(
  "Code",
  function (...) vim.lsp.buf.code_action() end,
  {}
)
