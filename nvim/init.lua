-- Questionable how much this caching actually improves performance.
vim.loader.enable()

-- Neovim will generate gb's of logs for some reason when logging is set to `WARN`.
vim.lsp.set_log_level(vim.lsp.log_levels.ERROR)

require('plugins')
require('sets')
require('mappings')
