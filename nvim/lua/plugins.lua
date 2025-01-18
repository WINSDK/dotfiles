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

local plugins = {
  -- Colors
  'sainnhe/gruvbox-material',
  
  -- LSP
  {
    'nvim-treesitter/nvim-treesitter',
    build = ":TSUpdate",
    config = function ()
        local configs = require("nvim-treesitter.configs")

        configs.setup({
          ensure_installed = {
              "markdown",
              "glsl",
              "wgsl",
              "go",
              "html",
              "css",
              "javascript",
              "python",
              "toml",
              "json",
              "lua",
              "bash",
              "comment",
              "c",
              "cpp",
              "lua",
              "rust",
              "ocaml"
          },
          sync_install = false,
          highlight = {
            enable = true
          },
          autotag = {
            enable = true
          }
        })
    end
  },

  'neovim/nvim-lspconfig',
  'nvim-lua/lsp_extensions.nvim',
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
  {
    "junegunn/fzf",
    build = "./install --bin"
  },
  'junegunn/fzf.vim',
  'tpope/vim-fugitive',
  'windwp/nvim-autopairs',
  'tpope/vim-commentary',
  
  -- View
  'airblade/vim-gitgutter',
  'nvim-lua/lsp-status.nvim',
  {
    "kawre/leetcode.nvim",
    -- build = ":TSUpdate html", -- if you have `nvim-treesitter` installed
    dependencies = {
      "nvim-telescope/telescope.nvim",
      -- "ibhagwan/fzf-lua",
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
    },
    opts = {
      lang = "python3",
      picker = "fzf-lua",
      theme = {
        ["alt"] = {
          -- bg = "#222222",
        },
        ["normal"] = {
          fg = "#FFFFFF",
        },
      },
    },
  }
}

require('lazy').setup(plugins)
