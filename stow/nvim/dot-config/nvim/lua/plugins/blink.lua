return {
  {
    "saghen/blink.cmp",
    opts = {
      completion = {
        list = {
          selection = {
            preselect = false,
            auto_insert = false,
          },
        },
      },
      keymap = {
        preset = "default",
        ["<CR>"] = { "accept", "fallback" },
        ["<Tab>"] = { "select_next", "fallback" },
        ["<S-Tab>"] = { "select_prev", "fallback" },
      },
    },
  },
}
