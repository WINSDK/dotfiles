local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"

if not vim.loop.fs_stat(lazypath) then
  vim.fn.system {
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- Latest stable release of lazy.nvim.
    lazypath,
  }
end

vim.opt.rtp:prepend(lazypath)

-- Recursively walk tree to check if we're in a node that *doesn't* require autocomplete.
local function no_autocomplete_required()
  local excluded_types = {
    string = true,
    string_content = true,
    quoted_string_content = true,
    comment = true,
    line_comment = true,
    block_comment = true
  }

  local node = require('nvim-treesitter.ts_utils').get_node_at_cursor(0, true)
  if not node then return false end
  while node do
    local ntype = node:type()
    if excluded_types[ntype] then
      return true
    end
    node = node:parent()
  end
  return false
end

function transform_lsp_items(_, items)
  -- Truly awful hack that disables autocompletion when treesitter
  -- realizes we're in a comment or string. For some reason ocaml and a couple
  -- other languages will autocomplete even when it makes no sense. 
  if no_autocomplete_required() then
    return {}
  end 

  -- Snippet support was removed here

  return vim.tbl_filter(
    function(item) return item.kind ~= require('blink.cmp.types').CompletionItemKind.Text end,
    items
  )
end

local plugins = {
  {
    "nvim-treesitter/nvim-treesitter", -- Code highlighting.
    build = ":TSUpdate",
    config = function()
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
  {
    "saghen/blink.cmp", -- LSP completion and documentation.
    dependencies = { "neovim/nvim-lspconfig" },
    version = "*",
    opts = {
      keymap = {
        preset = "none",
        ["<Tab>"] = { "select_next", "fallback" },
        ["<S-Tab>"] = { "select_prev", "fallback" },
        ["<CR>"] = { "accept", "fallback" },
      },
      completion = {
        menu = {
          draw = {
            columns = { { "label" }, { "kind" } },
            components = {
              kind = {
                text = function(ctx)
                  return ctx.kind:sub(1, 1)
                end,
              },
              label = {
                width = { fill = true, max = 30 },
                highlight = function(ctx)
                  -- label and label details
                  local highlights = {
                    { 0, #ctx.label, group = 'BlinkCmpLabel' },
                  }
                  if ctx.label_detail then
                    table.insert(highlights, {
                      #ctx.label,
                      #ctx.label + #ctx.label_detail,
                      group = 'BlinkCmpLabel'
                   })
                  end

                  -- characters matched on the label by the fuzzy matcher
                  for _, idx in ipairs(ctx.label_matched_indices) do
                    table.insert(highlights, { idx, idx + 1, group = 'BlinkCmpLabelMatch' })
                  end

                  return highlights
                end
              }
            }
          }
        },
        documentation = {
          auto_show = true,
          auto_show_delay_ms = 50,
          update_delay_ms = 50,
          window = {
            direction_priority = {
              menu_north = { "e" },
              menu_south = { "e" },
            }
          }
        }
      },
      sources = {
        default = { "lsp", "path" },
        cmdline = {},
        providers = { lsp = { transform_items = transform_lsp_items } }
      },
    },
  },
  {
    "neovim/nvim-lspconfig", -- Different lsp configs.
    dependencies = { "saghen/blink.cmp", "nvim-lua/lsp-status.nvim" },
    opts = {
      servers = {
        rust_analyzer = {
          settings = {
            ["rust-analyzer"] = {
              cargo = {
                buildScripts = {
                  enable = true
                },
                loadOutDirsFromCheck = true
              },
              checkOnSave = {
                allTargets = false
              },
              procMacro = {
                enable = true
              },
              diagnostics = {
                disabled = {"inactive-code", "unresolved-proc-macro", "mismatched-arg-count"},
                enableExperimental = true
              }
            }
          }
        },
        clangd = {
          root_dir = function()
            local path = vim.fs.find({"compile_commands.json", ".git"}, { upward = true })[1]
            return vim.fs.dirname(path)
          end
        },
        ocamllsp = {},
        pyright = {},
      }
    },
    config = function(_, opts)
      local lsp_status = require('lsp-status')

      lsp_status.config({
        status_symbol = '',
        current_function = false,
        indicator_errors = '%#DiagnosticError#E%*',
        indicator_warnings = '%#DiagnosticWarn#W%*',
        indicator_info = '%#DiagnosticInfo#i%*',
        indicator_hint = '%#DiagnosticHint#?%*',
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

      local lspconfig = require("lspconfig")
      local blink = require("blink.cmp")

      for server, config in pairs(opts.servers) do
        local capabilities = blink.get_lsp_capabilities(config.capabilities)
        local capabilities = vim.tbl_extend("keep", capabilities or {}, lsp_status.capabilities)

        config.capabilities = capabilities
        lspconfig[server].setup(config)
      end
    end,
  },
  {
    "junegunn/fzf",
    build = "./install --bin"
  },
  {
    "junegunn/fzf.vim", -- Fuzzy file and content search.
    dependencies = { "junegunn/fzf" },
    config = function()
      vim.opt.rtp:append("~/.fzf")

      if vim.fn.executable("rg") then
        vim.g.rg_derive_root = true
        vim.env.FZF_DEFAULT_COMMAND = "rg --files"
        vim.env.FZF_DEFAULT_OPTS = "--reverse"
      end

      vim.g["fzf_layout"] = {
        ["down"] = "~30%"
      }

      vim.g["fzf_action"] = {
        ["ctrl-v"] = "vsplit",
        ["ctrl-s"] = "split"
      }
    end
  },
  {
    "windwp/nvim-autopairs", -- Auto close brackets.
    config = function()
      require("nvim-autopairs").setup { check_ts = true }
    end
  },
  { 
    "kawre/leetcode.nvim", -- Pain.
    lazy = true,
    dependencies = {
      "nvim-telescope/telescope.nvim",
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
  },
  "sainnhe/gruvbox-material", -- Colortheme.
  "nvim-lua/lsp-status.nvim", -- Status bar.
  "tpope/vim-fugitive", -- Mainly for :Gdiff.
  "tpope/vim-commentary", -- Comment stuff out.
  "airblade/vim-gitgutter", -- git "+" and "-" on sidebar.
}

require("lazy").setup(plugins)
