return {
  {
    "p00f/clangd_extensions.nvim",
    opts = {},
    config = function()
      require("clangd_extensions").setup()
    end,
  }
}
