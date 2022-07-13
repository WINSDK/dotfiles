vim.opt.rtp:append("~/.fzf")

if vim.fn.executable('rg') then
  vim.g.rg_derive_root = true
  vim.env.FZF_DEFAULT_COMMAND = "rg --files"
  vim.env.FZF_DEFAULT_OPTS = "--reverse"
end

vim.g['fzf_layout'] = {
  ['down'] = '~30%'
}

vim.g['fzf_action'] = {
  ['ctrl-v'] = 'vsplit',
  ['ctrl-s'] = 'split'
}
