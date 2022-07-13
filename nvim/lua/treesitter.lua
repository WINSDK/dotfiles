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
