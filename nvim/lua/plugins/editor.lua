return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    opts = function(_, opts)
      opts.window = {
        position = "left",
        width = 30,
      }

      opts.default_component_configs = {
        indent = {
          with_expanders = false,
        },
      }

      opts.filesystem = {
        filtered_items = {
          visible = true,
        },
      }
    end,
  },

  {
    "saghen/blink.cmp",
    opts = {
      keymap = {
        preset = "none",
        ["<Tab>"] = {
          function(cmp)
            -- 1. 如果菜单显示，直接确认第一项
            if cmp.is_visible() then
              return cmp.accept()
            -- 2. 如果是 Snippet 占位符，跳到下一个
            elseif cmp.snippet_active() then
              return cmp.snippet_forward()
            -- 3. 关键判断：如果光标前有文字，尝试弹出补全
            elseif has_words_before() then
              return cmp.show()
            end
            -- 4. 否则（前面是空格或行首），执行默认 Tab 行为
          end,
          "fallback",
        },
        ["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" },
        ["<Up>"] = { "select_prev", "fallback" },
        ["<Down>"] = { "select_next", "fallback" },
        ["<CR>"] = { "accept", "fallback" },
      },
      completion = {
        list = {
          selection = {
            preselect = true,
            auto_insert = false,
          },
        },
      },
    },
    -- 辅助函数：判断光标前是否有文字
    config = function(_, opts)
      has_words_before = function()
        local line, col = unpack(vim.api.nvim_win_get_cursor(0))
        return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
      end
      require("blink.cmp").setup(opts)
    end,
  },
}
