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

-- Status bar on bottom (lsp progress)
local server = require('lspconfig')
local on_attach = function(client, bufnr)
  statusline.on_attach(client)
end

-- Lsp front-end helper functions
local has_words_before = function()
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end

local feedkey = function(key, mode)
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(key, true, true, true), mode, true)
end

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
  mapping = {
      ['<CR>'] = cmp.mapping.confirm({ select = true }),
      ["<Tab>"] = cmp.mapping(function(fallback)
        if cmp.visible() then
          cmp.select_next_item()
        elseif vim.fn["vsnip#available"](1) == 1 then
          feedkey("<Plug>(vsnip-expand-or-jump)", "")
        elseif has_words_before() then
          cmp.complete()
        else
          fallback()
        end
      end, { "i", "s" }),
      ["<S-Tab>"] = cmp.mapping(function()
        if cmp.visible() then
          cmp.select_prev_item()
        elseif vim.fn["vsnip#jumpable"](-1) == 1 then
          feedkey("<Plug>(vsnip-jump-prev)", "")
        end
      end, { "i", "s" }),
  },
  snippet = {
    expand = function(args)
      vim.fn["vsnip#anonymous"](args.body)
    end,
  },
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

if vim.fn.executable('pyright') == 0 then
    print("pyright not found")
end

server.pyright.setup {
    on_attach = on_attach,
    capabilities = capabilities,
}

if vim.fn.executable('rust-analyzer') == 0 then
    print("rust-analyzer not found")
    print("`rustup component add rust-analyzer`")
end

-- Rust analyzer LSP
server.rust_analyzer.setup {
  on_attach = on_attach,
  capabilities = capabilities,
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
        enable = false
      },
      diagnostics = {
        disabled = {"inactive-code", "unresolved-proc-macro", "mismatched-arg-count"},
        enableExperimental = true
      }
    }
  }
}

if vim.fn.executable('rust-analyzer') == 0 then
  print("clangd not found")
end

-- Clangd LSP
server.clangd.setup {
  on_attach = on_attach,
  capabilities = capabilities,
  root_dir = function()
    return vim.fs.dirname(vim.fs.find({"compile_commands.json", ".git"}, { upward = true })[1])
  end
}

-- Occaml LSP
server.ocamllsp.setup {
  on_attach = on_attach,
  capabilities = capabilities,
}

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
