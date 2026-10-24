return {
  {
    "catgoose/nvim-colorizer.lua",
    event = "VeryLazy",
    opts = {
      filetypes = { "*" },
      options = {
        parsers = {
          hex = { default = true },
        },
        display = {
          mode = "background",
        },
      },
    },
  },
}
