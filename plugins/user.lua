return {
  -- You can also add new plugins here as well:
  -- Add plugins, the lazy syntax
  -- "andweeb/presence.nvim",
  {
    "tpope/vim-surround",
    event = "BufRead",
  },
  {
    "ray-x/lsp_signature.nvim",
    event = "BufRead",
    config = function() require("lsp_signature").setup() end,
  },
  "chiendo97/intellij.vim",
  {
    "nvim-neotest/neotest",
    config = function()
      -- get neotest namespace (api call creates or returns namespace)
      local neotest_ns = vim.api.nvim_create_namespace "neotest"
      vim.diagnostic.config({
        virtual_text = {
          format = function(diagnostic)
            local message = diagnostic.message:gsub("\n", " "):gsub("\t", " "):gsub("%s+", " "):gsub("^%s+", "")
            return message
          end,
        },
      }, neotest_ns)
      require("neotest").setup {
        -- your neotest config here
        adapters = {
          require "neotest-go" {
            runner = "testify",
            experimental = {
              test_table = true,
            },
            args = { "-count=1", "-timeout=5s" },
          },
          require "neotest-rust",
          require "neotest-python",
        },
      }
    end,
    ft = { "go", "rust", "python" },
    dependencies = {
      "nvim-neotest/neotest-go",
      "nvim-neotest/neotest-python",
      "rouge8/neotest-rust",
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      "antoinemadec/FixCursorHold.nvim",
    },
  },
}
