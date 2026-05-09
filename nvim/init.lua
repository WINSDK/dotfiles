-- Questionable how much this caching actually improves performance.
vim.loader.enable()

-- Neovim will generate gb's of logs for some reason when logging is set to `WARN`.
vim.lsp.log.set_level(vim.lsp.log.levels.ERROR)

require('plugins')
-- require('conway')
require('sets')
require('keymaps')
require('functions')
