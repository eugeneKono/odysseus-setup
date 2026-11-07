return {
  {
    "catgoose/nvim-colorizer.lua",
    lazy = false,
    opts = {
      filetypes = { "*" },

      user_default_options = {
        names = false,
        RGB = true,
        RRGGBB = true,
        RGBA = false,
        RRGGBBAA = false,
        AARRGGBB = false,
        rgb_fn = true,
        hsl_fn = false,
        css = false,
        css_fn = false,
        tailwind = false,
        mode = "background",
      },
    },
  },
}
