local fn = vim.fn
local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
if fn.empty(fn.glob(install_path)) > 0 then
  fn.system({'git', 'clone', 'https://github.com/wbthomason/packer.nvim', install_path})
  vim.cmd 'packadd packer.nvim'
end

return require('packer').startup(function(use)
  -- Colors
  use 'sainnhe/gruvbox-material'
  
  -- LSP
  use { 'nvim-treesitter/nvim-treesitter', run = ':TSUpdate' }
  use 'neovim/nvim-lspconfig'
  use 'nvim-lua/lsp_extensions.nvim'
  use 'onsails/lspkind-nvim'
  use {
    "hrsh7th/nvim-cmp",
    requires = {
      "hrsh7th/vim-vsnip",
      "hrsh7th/cmp-nvim-lsp",
	    "hrsh7th/cmp-nvim-lua",
	    "hrsh7th/cmp-path",
      "f3fora/cmp-spell"
    }
  }
  
  -- Navigation
  use { 'junegunn/fzf', run = 'fzf#install()' }
  use 'junegunn/fzf.vim'
  use 'tpope/vim-fugitive'
  use 'windwp/nvim-autopairs'
  
  -- View
  use {'iamcco/markdown-preview.nvim', run = [[sh -c 'cd app && yarn install']]}
  use 'airblade/vim-gitgutter'
  use 'glepnir/dashboard-nvim'
end)
