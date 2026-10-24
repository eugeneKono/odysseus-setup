return {
  {
    "shaunsingh/nord.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      vim.g.nord_bold = true
      vim.g.nord_italic = false
      vim.g.nord_underline = true
      vim.g.nord_undercurl = true
      vim.g.nord_disable_background = true
      vim.g.nord_cursor_line_number_background = true
      vim.g.nord_comment_brightness = 12
      vim.cmd.colorscheme("nord")
    end,
  },
}
