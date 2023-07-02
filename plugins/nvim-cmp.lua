return {
  {
    "L3MON4D3/LuaSnip",
    opts = function(_, opts)
      local ls = require "luasnip"

      local snippet_from_nodes = ls.sn

      local s = ls.s
      local i = ls.insert_node
      local t = ls.text_node
      local d = ls.dynamic_node
      local c = ls.choice_node
      local fmta = require("luasnip.extras.fmt").fmta
      local rep = require("luasnip.extras").rep

      local ts_locals = require "nvim-treesitter.locals"
      local ts_utils = require "nvim-treesitter.ts_utils"

      local get_node_text = vim.treesitter.get_node_text

      local transforms = {
        int = function(_, _) return t "0" end,

        bool = function(_, _) return t "false" end,

        string = function(_, _) return t [[""]] end,

        error = function(_, info)
          if info then
            info.index = info.index + 1

            return c(info.index, {
              t(info.err_name),
              t(string.format('fmt.Errorf("%s: %%w", %s)', info.func_name, info.err_name)),
            })
          else
            return t "err"
          end
        end,

        -- Types with a "*" mean they are pointers, so return nil
        [function(text) return string.find(text, "*", 1, true) ~= nil end] = function(_, _) return t "nil" end,
      }

      local transform = function(text, info)
        local condition_matches = function(condition, ...)
          if type(condition) == "string" then
            return condition == text
          else
            return condition(...)
          end
        end

        for condition, result in pairs(transforms) do
          if condition_matches(condition, text, info) then return result(text, info) end
        end

        return t(text)
      end

      local handlers = {
        parameter_list = function(node, info)
          local result = {}

          local count = node:named_child_count()
          for idx = 0, count - 1 do
            local matching_node = node:named_child(idx)
            local type_node = matching_node:field("type")[1]
            table.insert(result, transform(get_node_text(type_node, 0), info))
            if idx ~= count - 1 then table.insert(result, t { ", " }) end
          end

          return result
        end,

        type_identifier = function(node, info)
          local text = get_node_text(node, 0)
          return { transform(text, info) }
        end,
      }

      local function_node_types = {
        function_declaration = true,
        method_declaration = true,
        func_literal = true,
      }

      local function go_result_type(info)
        local cursor_node = ts_utils.get_node_at_cursor()
        local scope = ts_locals.get_scope_tree(cursor_node, 0)

        local function_node
        for _, v in ipairs(scope) do
          if function_node_types[v:type()] then
            function_node = v
            break
          end
        end

        if not function_node then
          print "Not inside of a function"
          return t ""
        end

        local query = vim.treesitter.query.parse(
          "go",
          [[
      [
        (method_declaration result: (_) @id)
        (function_declaration result: (_) @id)
        (func_literal result: (_) @id)
      ]
    ]]
        )
        for _, node in query:iter_captures(function_node, 0) do
          if handlers[node:type()] then return handlers[node:type()](node, info) end
        end
      end

      local go_ret_vals = function(args)
        return snippet_from_nodes(
          nil,
          go_result_type {
            index = 0,
            err_name = args[1][1],
            func_name = args[2][1],
          }
        )
      end

      ls.add_snippets("go", {
        s(
          "efi",
          fmta(
            [[
<val>, <err> := <f>(<args>)
if <err_same> != nil {
	return <result>
}
<finish>
]],
            {
              val = i(1),
              err = i(2, "err"),
              f = i(3),
              args = i(4),
              err_same = rep(2),
              result = d(5, go_ret_vals, { 2, 3 }),
              finish = i(0),
            }
          )
        ),
      })

      return opts
    end,
  },
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "saadparwaiz1/cmp_luasnip",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-nvim-lsp",
    },
    event = "InsertEnter",
    opts = function(_, opts)
      local cmp, copilot = require "cmp", require "copilot.suggestion"
      local snip_status_ok, luasnip = pcall(require, "luasnip")
      if not snip_status_ok then return end

      opts.mapping["<C-h>"] = cmp.mapping(function()
        if luasnip.choice_active() then luasnip.change_choice(1) end
      end)
      opts.mapping["<C-x>"] = cmp.mapping(function()
        if copilot.is_visible() then copilot.next() end
      end)
      opts.mapping["<C-z>"] = cmp.mapping(function()
        if copilot.is_visible() then copilot.prev() end
      end)
      opts.mapping["<C-l>"] = cmp.mapping(function()
        if copilot.is_visible() then
          copilot.accept_word()
        elseif luasnip.choice_active() then
          luasnip.change_choice(1)
        end
      end)
      opts.mapping["<C-j>"] = cmp.mapping(function()
        if copilot.is_visible() then copilot.accept_line() end
      end)

      opts.mapping["<Tab>"] = cmp.mapping(function(fallback)
        if copilot.is_visible() then
          copilot.accept()
        elseif luasnip.expand_or_jumpable() then
          luasnip.expand_or_jump()
        else
          fallback()
        end
      end, { "i", "s" })

      opts.mapping["<S-Tab>"] = cmp.mapping(function(fallback)
        if luasnip.jumpable(-1) then
          luasnip.jump(-1)
        else
          fallback()
        end
      end, { "i", "s" })

      return opts
    end,
  },
}
