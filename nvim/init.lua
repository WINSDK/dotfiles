--require("profile").start("/tmp/nvim_profile.log", { flame = true })

require('plugins')
require('sets')
require("custom_lspconfig")
require('mappings')

--require("profile").stop()
