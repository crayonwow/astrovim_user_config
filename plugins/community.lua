return {
  -- Add the community repository of plugin specifications
  "AstroNvim/astrocommunity",
  -- example of imporing a plugin, comment out to use it or add your own
  -- available plugins can be found at https://github.com/AstroNvim/astrocommunity

  { import = "astrocommunity.colorscheme.catppuccin" },
  { import = "astrocommunity.completion.copilot-lua-cmp" },
  { import = "astrocommunity.colorscheme.rose-pine" },
  { import = "astrocommunity.colorscheme.vscode-nvim" },
  -- { import = "astrocommunity.motion.nvim-spider" },
  { import = "astrocommunity.scrolling.satellite-nvim" },
  { import = "astrocommunity.test.nvim-coverage" },
  { import = "astrocommunity.utility.neodim" },
}
