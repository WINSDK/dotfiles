local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'

if not vim.loop.fs_stat(lazypath) then
  vim.fn.system {
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable', -- latest stable release
    lazypath,
  }
end

vim.opt.rtp:prepend(lazypath)

return require('lazy').setup({
  -- Colors
  'sainnhe/gruvbox-material',

  -- Useless nonesense
  'eandrju/cellular-automaton.nvim',
  
  -- LSP
  {
    'nvim-treesitter/nvim-treesitter',
    config = function()
      pcall(require('nvim-treesitter.install').update { with_sync = true })
    end,
  },

  'neovim/nvim-lspconfig',
  'nvim-lua/lsp_extensions.nvim',
  'onsails/lspkind-nvim',
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/vim-vsnip",
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-nvim-lua",
      "hrsh7th/cmp-path"
    }
  },
  
  -- Navigation
  { 'junegunn/fzf', run = 'fzf#install()' },
  'junegunn/fzf.vim',
  'tpope/vim-fugitive',
  'windwp/nvim-autopairs',
  
  -- View
  'airblade/vim-gitgutter',
  'nvim-lua/lsp-status.nvim'
}, {})
