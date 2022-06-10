-- Neovim will generate gb's of logs for some reason when logging is set to `WARN`.
vim.lsp.set_log_level(vim.lsp.log_levels.ERROR)

local server = require('lspconfig')
local on_attach = function(client, bufnr)
  local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
  local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end
  local opts = { noremap = true, silent = true }

  -- LSP Code Navigation
  buf_set_keymap("n", "~",  "<Cmd> lua vim.lsp.diagnostic.show_line_diagnostics()<CR>", opts)
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

local check_back_space = function()
  local col = vim.fn.col '.' - 1
  return col == 0 or vim.fn.getline('.'):sub(col, col):match '%s' ~= nil
end

local t = function(str)
    return vim.api.nvim_replace_termcodes(str, true, true, true)
end

local cmp = require('cmp')
cmp.setup {
  mapping = {
    ["<Tab>"] = cmp.mapping(function(fallback)
      if vim.fn.pumvisible() == 1 then
        vim.fn.feedkeys(vim.api.nvim_replace_termcodes('<C-n>', true, true, true), 'n')
      elseif check_back_space() then
        vim.fn.feedkeys(vim.api.nvim_replace_termcodes('<Tab>', true, true, true), 'n')
      elseif vim.fn['vsnip#available']() == 1 then
        vim.fn.feedkeys(vim.api.nvim_replace_termcodes('<Plug>(vsnip-expand-or-jump)', true, true, true), '')
      else
        fallback()
      end
    end, {"i", "s"}),
    ["<S-Tab>"] = cmp.mapping(function(fallback)
      if vim.fn.pumvisible() == 1 then
        vim.fn.feedkeys(t("<C-p>"), "n")
      else
        fallback()
      end
    end, {"i", "s"}),
    ['<CR>'] = cmp.mapping.confirm({
      behavior = cmp.ConfirmBehavior.Replace,
      select = true
    })
  },
  formatting = {
    format = function(_, vim_item)
      vim_item.kind = lspkind.presets.default[vim_item.kind]
      return vim_item
    end
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
    { name = 'path' }
  }
}

--[[
depends on the binaries: rust-analyzer, clangd, pyright and optionally the vscode plugin binaries:
typescript-language-server, vscode-css-languageserver-bin,
vscode-html-languageserver-bin and vscode-json-languageserver 

https://github.com/georgewfraser/java-language-server.git
--]]

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())

local servers = {'jsonls', 'tsserver', 'cssls', 'html', 'pyright', 'clangd', 'java_language_server'}
for _, lsp in ipairs(servers) do
  server[lsp].setup { 
    on_attach = on_attach;
    capabilities = capabilities;
  }
end

server.java_language_server.setup {
  on_attach = on_attach;
  capabilities = capabilities;
  cmd = { "/Users/nicolas/Repos/java-language-server/dist/launch_mac.sh" };
}

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

-- Visual diagnostics
vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
  vim.lsp.diagnostic.on_publish_diagnostics, {
    virtual_text = true,
    signs = false,
    update_in_insert = false,
    underline = true,
  }
)

-- nvim-treesitter
require('nvim-treesitter.configs').setup {
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
      "rust"
  },
  highlight = {
    enable = true
  },
  autotag = {
    enable = true
  }
}

-- AutoPairs
require("nvim-autopairs").setup {
  check_ts = true,
}

local cmp_autopairs = require('nvim-autopairs.completion.cmp')
cmp.event:on('confirm_done', cmp_autopairs.on_confirm_done({  map_char = { tex = '' } }))
