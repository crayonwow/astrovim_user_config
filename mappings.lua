local utils = require "astronvim.utils"
local is_available = utils.is_available
local get_icon = utils.get_icon
-- Mapping data with "desc" stored directly by vim.keymap.set().
--
-- Please use this mappings table to set keyboard mapping since this is the
-- lower level configuration and more robust one. (which-key will
-- automatically pick-up stored data by this setting.)
local maps = {
  n = {
    ["<leader>t"] = { desc = "Test" },
    ["<leader>T"] = { desc = get_icon("Terminal", 1, true) .. "Terminal" },
    ["<leader>tn"] = { function() require("neotest").run.run() end, desc = "Nearest" },
    ["<leader>tt"] = { function() require("neotest").summary.toggle() end, desc = "Toggle" },

    ["<C-n>"] = { "<cmd>Neotree toggle<cr>", desc = "Toggle Explorer" },

    ["<leader>im"] = [[<cmd>lua require'telescope'.extensions.goimpl.goimpl{}<CR>]],

    -- disable some mappings
    ["<leader>e"] = false,
    ["<leader>o"] = false,
    ["<leader>tl"] = false,
    ["<leader>tn"] = false,
    ["<leader>tu"] = false,
    ["<leader>tp"] = false,
    ["<leader>th"] = false,
    ["<leader>tf"] = false,
    ["<leader>tv"] = false,
  },
  t = {},
}

maps.n["<leader>fw"] = {
  function()
    require("telescope.builtin").live_grep {
      file_ignore_patterns = {
        "vendor",
      },
    }
  end,
  desc = "Find words",
}

if is_available "toggleterm.nvim" then
  maps.n["<leader>T"] = { desc = " Terminal" }
  if vim.fn.executable "lazygit" == 1 then
    maps.n["<leader>Tl"] = { function() utils.toggle_term_cmd "lazygit" end, desc = "ToggleTerm lazygit" }
  end
  if vim.fn.executable "node" == 1 then
    maps.n["<leader>Tn"] = { function() utils.toggle_term_cmd "node" end, desc = "ToggleTerm node" }
  end
  if vim.fn.executable "gdu" == 1 then
    maps.n["<leader>Tu"] = { function() utils.toggle_term_cmd "gdu" end, desc = "ToggleTerm gdu" }
  end
  if vim.fn.executable "btm" == 1 then
    maps.n["<leader>Tt"] = { function() utils.toggle_term_cmd "btm" end, desc = "ToggleTerm btm" }
  end
  local python = vim.fn.executable "python" == 1 and "python" or vim.fn.executable "python3" == 1 and "python3"
  if python then maps.n["<leader>Tp"] = { function() utils.toggle_term_cmd(python) end, desc = "ToggleTerm python" } end
  maps.n["<leader>Tf"] = { "<cmd>ToggleTerm direction=float<cr>", desc = "ToggleTerm float" }
  maps.n["<leader>Th"] = { "<cmd>ToggleTerm size=10 direction=horizontal<cr>", desc = "ToggleTerm horizontal split" }
  maps.n["<leader>Tv"] = { "<cmd>ToggleTerm size=80 direction=vertical<cr>", desc = "ToggleTerm vertical split" }
end

return maps
