-- Neovim will generate gb's of logs for some reason when logging is set to `WARN`.
vim.lsp.set_log_level(vim.lsp.log_levels.ERROR)

local server = require('lspconfig')
local on_attach = function(client, bufnr)
  local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
  local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end
  local opts = { noremap = true, silent = true }

  -- LSP Code Navigation
  buf_set_keymap("n", "~",  "<Cmd> lua vim.diagnostic.open_float()<CR>", opts)
  buf_set_keymap("n", "gd", "<Cmd> lua vim.lsp.buf.definition()<CR>", opts)
  buf_set_keymap("n", "gi", "<Cmd> lua vim.lsp.buf.implementation()<CR>", opts)
  buf_set_keymap("n", "gt", "<Cmd> lua vim.lsp.buf.type_definition()<CR>", opts)
  buf_set_keymap("n", "gs", "<Cmd> lua vim.lsp.buf.document_symbol()<CR>", opts)
  buf_set_keymap("n", "ge", "<Cmd> lua vim.lsp.buf.declaration()<CR>", opts)
  buf_set_keymap("n", "gj", "<Cmd> lua vim.lsp.buf.code_action()<CR>", opts)

  if client.resolved_capabilities.document_formatting then
    buf_set_keymap("n", "<F3>", "<Cmd> lua vim.lsp.buf.formatting()<CR>", opts)
  elseif client.resolved_capabilities.document_range_formatting then
    buf_set_keymap("n", "<F3>", "<Cmd> lua vim.lsp.buf.range_formatting()<CR>", opts)
  end
end

-- Icons for LSP window
local lspkind = require('lspkind')
lspkind.init {
  mode = 'symbol_text',
  preset = 'codicons',
  symbol_map = {
    Text = "",
    Method = "",
    Function = "",
    Constructor = "",
    Field = "ﰠ",
    Variable = "",
    Class = "ﴯ",
    Interface = "",
    Module = "",
    Property = "ﰠ",
    Unit = "塞",
    Value = "",
    Enum = "",
    Keyword = "",
    Snippet = "",
    Color = "",
    File = "",
    Reference = "",
    Folder = "",
    EnumMember = "",
    Constant = "",
    Struct = "פּ",
    Event = "",
    Operator = "",
    TypeParameter = ""
  },
}

-- Lsp front-end helper functions
local has_words_before = function()
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end

local feedkey = function(key, mode)
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(key, true, true, true), mode, true)
end

-- Lsp front-end
local cmp = require('cmp')
cmp.setup {
  formatting = {
    format = function(_, vim_item)
      vim_item.kind = lspkind.presets.default[vim_item.kind]
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

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())

local binaries = {
    { 'pyright', 'pyright', '`pip install pyright`' },
    { 'clangd', 'clangd', 'install llvm or `npm i --location=global @clangd/install`' },
    { 'tsserver', 'typescript-language-server', '`npm i --location=global typescript-language-server`' },
    { 'cssls', 'vscode-css-language-server', '`npm i --location=global vscode-langservers-extracted`' },
    { 'html', 'vscode-html-language-server', '`npm i --location=global vscode-langservers-extracted`' },
    { 'jsonls', 'vscode-json-language-server', '`npm i --location=global vscode-langservers-extracted`' },
}

for _, triplet in ipairs(binaries) do
    local lsp, binary, command = triplet[1], triplet[2], triplet[3]

    if vim.fn.executable(binary) == 0 then
        print(binary .. " not found")
        print(command)
        print(" ")
    end

    server[lsp].setup {
      on_attach = on_attach;
      capabilities = capabilities;
    }
end

if vim.fn.executable('rust-analyzer') == 0 then
    print('rust-analyzer not found')
    print('`rustup +nightly component add rust-analyzer-preview`')
end

-- Rust analyzer LSP
server.rust_analyzer.setup {
  on_attach = on_attach;
  capabilities = capabilities;
  settings = {
    ["rust-analyzer"] = {
      cargo = {
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
