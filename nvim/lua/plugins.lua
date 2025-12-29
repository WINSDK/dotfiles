local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

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
local function autocomplete_required()
  local excluded_types = {
    "string",
    "string_content",
    "quoted_string_content",
    "comment",
    "line_comment",
    "block_comment",
  }

  local node = require("nvim-treesitter.ts_utils").get_node_at_cursor(0, true)
  if not node then return false end
  while node do
    local ntype = node:type()
    if vim.tbl_contains(excluded_types, ntype) then
      return false
    end
    node = node:parent()
  end
  return true
end

function transform_lsp_items(a, items)
  local kinds = require("blink.cmp.types").CompletionItemKind
  local keyword = a.get_keyword()
  local filter = { kinds.Text, kinds.Keyword }
  return vim.tbl_filter(
    function(item)
      return not vim.tbl_contains(filter, item.kind)
    end,
    items
  )
end

local plugins = {
  "danielo515/nvim-treesitter-reason",
  {
    "nvim-treesitter/nvim-treesitter", -- Code highlighting.
    dependencies = { "danielo515/nvim-treesitter-reason" },
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
          "ocaml",
          "haskell",
          "reason",
        },
        sync_install = false,
        highlight = {
          enable = true,
          additional_vim_regex_highlighting = true,
        },
        autotag = {
          enable = true
        },
        indent = {
          enable = false
        }
      })
    end
  },
  {
    "saghen/blink.cmp", -- LSP completion and documentation.
    version = "1.*",
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
                    { 0, #ctx.label, group = "BlinkCmpLabel" },
                  }
                  if ctx.label_detail then
                    table.insert(highlights, {
                      #ctx.label,
                      #ctx.label + #ctx.label_detail,
                      group = "BlinkCmpLabel"
                   })
                  end

                  -- characters matched on the label by the fuzzy matcher
                  for _, idx in ipairs(ctx.label_matched_indices) do
                    table.insert(highlights, { idx, idx + 1, group = "BlinkCmpLabelMatch" })
                  end

                  return highlights
                end
              }
            }
          },
        },
        documentation = {
          auto_show = false,
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
      cmdline = {
        enabled = false
      },
      sources = {
        default = { "lsp", "path" },
        providers = {
          lsp = {
            transform_items = transform_lsp_items,
            should_show_items = function(ctx)
              -- More hacks to not show autocompletion on common keywords.
              -- Don't know why this doesn't already exist in blink.cmp
              -- local filter = { "while", "then", "if", "let", "type", "in", "with" }
              -- if vim.tbl_contains(filter, ctx.get_keyword()) then
              --   return false
              -- end 

              -- Truly awful hack that disables autocompletion when treesitter
              -- realizes we're in a comment or string. For some reason ocaml and a couple
              -- other languages will autocomplete even when it makes no sense. 
              return autocomplete_required()
            end,
          }
        }
      },
    },
  },
  {
    "neovim/nvim-lspconfig", -- Different lsp configs.
    dependencies = { "WINSDK/lsp-status.nvim", "saghen/blink.cmp" },
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
          cmd = {
            "clangd",
            "--background-index",
            "--clang-tidy",
            "--compile-commands-dir=build"
          },
          -- https://clangd.llvm.org/installation#neovim-built-in-lsp-client
          init_options = {
            fallbackFlags = { "-std=c++23", "-fexperimental-library", "-stdlib=libc++" },
          },
        },
        ruff = {},
        ty = {},
        ocamllsp = {},
        hls = {},
      }
    },
    config = function(_, opts)
      local lsp_status = require("lsp-status")

      lsp_status.config({
        status_symbol = "",
        current_function = false,
        indicator_errors = "%#DiagnosticError#E%*",
        indicator_warnings = "%#DiagnosticWarn#W%*",
        indicator_info = "%#DiagnosticInfo#i%*",
        indicator_hint = "%#DiagnosticHint#?%*",
        indicator_ok = "",
      })

      lsp_status.register_progress()

      function show_lsp_status()
        if #vim.lsp.buf_get_clients() > 0 then
          return lsp_status.status()
        end
        return ""
      end

      vim.o.statusline = "%{%v:lua.show_lsp_status()%}"

      local blink = require("blink.cmp")

      for server, config in pairs(opts.servers) do
        local capabilities = blink.get_lsp_capabilities(config.capabilities)
        local capabilities = vim.tbl_extend("keep", capabilities or {}, lsp_status.capabilities)
        config.capabilities = capabilities

        vim.lsp.config(server, config)
        vim.lsp.enable(server)
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
    "WINSDK/modus-themes.nvim",
    priority = 1000,
    config = function()
      require("modus-themes").setup {
        line_nr_column_background = false,
        styles = {
          comments = { italic = false },
          keywords = { italic = false },
          functions = {},
          variables = {},
        }
      }
    end
  },
  "WINSDK/lsp-status.nvim", -- Status bar.
  "tpope/vim-fugitive", -- Mainly for :Gdiff.
  "tpope/vim-commentary", -- Comment stuff out.
  "airblade/vim-gitgutter", -- git "+" and "-" on sidebar.
  {
    "julienvincent/hunk.nvim",
    cmd = { "DiffEditor" },
    config = function()
      require("hunk").setup({
        icons = {
          selected           = "▍",
          deselected         = "-",
          partially_selected = "▎",

          folder_open        = "▾",
          folder_closed      = "▸",

          expanded           = "▾",
          collapsed          = "▸",
        },
        keys = {
          diff = {
            prev_hunk = { "<S-k>" },
            next_hunk = { "<S-j>" },
          },
        },
      })
    end,
    dependencies = { "MunifTanjim/nui.nvim" },
  },
}

require("lazy").setup(plugins)
