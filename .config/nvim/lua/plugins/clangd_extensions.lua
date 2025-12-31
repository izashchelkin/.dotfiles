return {
  {
    "p00f/clangd_extensions.nvim",
    enabled = false,
    opts = {},
    config = function()
      require("clangd_extensions").setup()
    end,
  }
}
