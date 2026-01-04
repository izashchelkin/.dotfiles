return {
  {
    "neovim/nvim-lspconfig",
    enabled = true,
    dependencies = {
      "saghen/blink.cmp",
      {
        "folke/lazydev.nvim",
        ft = "lua",
        opts = {
          library = {
            { path = "${3rd}/luv/library", words = { "vim%.uv" } },
          },
        },
      },
    },

    opts = {
      servers = {
        -- ruff = {},
        -- lua_ls = {},
        clangd = {
          cmd = {
            "clangd",
            "--pretty",
            "--background-index",
            "--clang-tidy",
            "--header-insertion=iwyu",
            "--completion-style=detailed",
            "--fallback-style=none",
          },
          root_markers = { "compile_commands.json", ".git" },
          init_options = {
            usePlaceholders = true,
            completeUnimported = false,
            clangdFileStatus = true,
          },
        },
      },
    },

    config = function(_, opts)
      for server, config in pairs(opts.servers) do
        config.capabilities =
          require("blink.cmp").get_lsp_capabilities(config.capabilities)

        vim.lsp.config(server, config)
        vim.lsp.enable(server)
      end

      vim.lsp.set_log_level("debug")
    end,
  },
}
