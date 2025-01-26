local statusline = require('statusline')

-- Neovim will generate gb's of logs for some reason when logging is set to `WARN`
vim.lsp.set_log_level(vim.lsp.log_levels.ERROR)

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup('UserLspConfig', {}),
  callback = function(ev)

    local function nnoremap(key, com)
        vim.keymap.set('n', key, com, { buffer = ev.buf })
    end

    nnoremap("~",  vim.diagnostic.open_float)
    nnoremap("gd", vim.lsp.buf.definition)
    nnoremap("gi", vim.lsp.buf.implementation)
    nnoremap("gt", vim.lsp.buf.type_definition)
    nnoremap("gs", vim.lsp.buf.document_symbol)
    nnoremap("ge", vim.lsp.buf.declaration)
    nnoremap("gj", vim.lsp.buf.code_action)
    nnoremap("<space>f", function() vim.lsp.buf.format { async = true } end)
  end,
})

local server = require('lspconfig')

local symbol_map = {
  Text = "TEXT",
  Method = "METH",
  Function = "FUNC",
  Constructor = "NEW",
  Field = "FIELD",
  Variable = "VAR",
  Class = "CLASS",
  Interface = "INTER",
  Module = "MOD",
  Property = "PROP",
  Unit = "UNIT",
  Value = "VAL",
  Enum = "ENUM",
  Keyword = "KEY",
  Snippet = "SNIP",
  Color = "COLOR",
  File = "FILE",
  Reference = "REF",
  Folder = "FOLD",
  EnumMember = "MEMBER",
  Constant = "CONST",
  Struct = "STRUCT",
  Event = "EVENT",
  Operator = "OP",
  TypeParameter = ""
}

-- Lsp front-end
local cmp = require('cmp')
cmp.setup {
  formatting = {
    format = function(_, vim_item)
      vim_item.kind = symbol_map[vim_item.kind]
      return vim_item
    end
  },
  mapping = cmp.mapping.preset.insert({
    ["<Tab>"] = cmp.mapping.select_next_item(),
    ["<S-Tab>"] = cmp.mapping.select_prev_item(),
    ["<CR>"] = cmp.mapping.confirm({ select = true })
  }),
  completion = {
    completeopt = 'menu,menuone,noinsert'
  },
  sources = {
    { name = 'nvim_lsp' },
    { name = 'nvim_lua' }, 
    { name = 'path' },
  }
}

local capabilities = require('cmp_nvim_lsp').default_capabilities()
local capabilities = vim.tbl_extend('keep', capabilities or {}, statusline.capabilities)

local servers = {
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
      return vim.fs.dirname(vim.fs.find({"compile_commands.json", ".git"}, { upward = true })[1])
    end
  },
  ocamllsp = {},
  pyright = {},
}

for name, config in pairs(servers) do
  local cmd = server[name].document_config.default_config.cmd[1]
  if vim.fn.executable(cmd) == 1 then
    server[name].on_attach = statusline.on_attach
    server[name].capabilities = capabilities
    server[name].setup(config)
  end
end

-- AutoPairs
require("nvim-autopairs").setup {
  check_ts = true,
}

local cmp_autopairs = require('nvim-autopairs.completion.cmp')
cmp.event:on('confirm_done', cmp_autopairs.on_confirm_done({  map_char = { tex = '' } }))

-- Visual diagnostics
vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
  vim.lsp.diagnostic.on_publish_diagnostics, {
    virtual_text = true,
    signs = false,
    update_in_insert = false,
    underline = true,
  }
)
