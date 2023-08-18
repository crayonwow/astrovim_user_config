local ops = {
  show_line = false,
}
return {
  n = {
    ["gi"] = { function() require("telescope.builtin").lsp_implementations(ops) end },
    ["gr"] = { function() require("telescope.builtin").lsp_references(ops) end },

    ["gI"] = false,
  },
}
