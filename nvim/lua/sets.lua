local set = vim.opt

set.mouse = "a"
set.relativenumber = true
set.number = true
set.spell = true

set.synmaxcol = 500
set.clipboard:append("unnamedplus")
set.diffopt:append("iwhite")
set.shortmess:append("c")

set.laststatus = 3

set.cmdheight = 1

set.autoindent = true
set.smartindent = true

set.lazyredraw = true
set.ignorecase = true
set.smartcase = true
set.scrolloff = 2
set.pumheight = 22

set.expandtab = true

set.termguicolors = true
set.updatetime = 1000
set.timeoutlen = 300
set.guicursor = "a:block-blinkon0"
set.background = "dark"
set.winborder = "bold"

vim.cmd.colorscheme("modus")

vim.g.netrw_browse_split = 0
vim.g.netrw_banner = 0
vim.g.netrw_winsize = 25

vim.g.completion_matching_strategy_list = { "exact", "substring", "fuzzy" }
vim.g.mapleader = " "

vim.filetype.add {
  extension = {
    metal = "cpp",
    re = "reason"
  },
}

vim.api.nvim_create_autocmd("Filetype", {
  pattern = "*",
  callback = function()
    local buf = vim.api.nvim_get_current_buf()
    local filetype = vim.api.nvim_buf_get_option(buf, "filetype")
    local sets = {
      python = { width = "80", tab = 4 },
      gitcommit = { width = "80", tab = 4 },
      markdown = { width = "80", tab = 2 },
      c = { width = "100", tab = 2 },
      cpp = { width = "100", tab = 2 },
      rust = { width = "100", tab = 4 },
      lua = { width = "100", tab = 2 },
      ocaml = { width = "100", tab = 2 },
      reason = { width = "80", tab = 2 },
      haskell = { width = "80", tab = 2 },
      dune = { width = "100", tab = 1 },
      css = { width = "80", tab = 2 },
      html = { width = "80", tab = 2 },
    }

    if sets[filetype] then
      set.colorcolumn = sets[filetype].width

      vim.bo[buf].tabstop     = sets[filetype].tab
      vim.bo[buf].shiftwidth  = sets[filetype].tab
      vim.bo[buf].softtabstop = sets[filetype].tab
    else
      set.colorcolumn = "100"

      vim.bo[buf].tabstop     = 4
      vim.bo[buf].shiftwidth  = 4
      vim.bo[buf].softtabstop = 4
    end
  end,
})
