return {
  {
    "neovim/nvim-lspconfig",
    enabled = false,
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
            -- "--background-index=false",
            "--pretty",
            "--clang-tidy",
            "--header-insertion=iwyu",
            "--completion-style=detailed",
            "--fallback-style=none",
          },
          root_markers = { "compile_commands.json", ".git" },
          init_options = {
            usePlaceholders = true,
            completeUnimported = true,
            clangdFileStatus = false,
          },
        },
      },
    },

    config = function(_, opts)
      for server, config in pairs(opts.servers) do
        config.capabilities =
          require("blink.cmp").get_lsp_capabilities(config.capabilities)

        if server == "clangd" and config.capabilities and config.capabilities.textDocument then
          config.capabilities.textDocument.semanticTokens = nil
        end

        vim.lsp.config(server, config)
        vim.lsp.enable(server)
      end

      vim.lsp.set_log_level("error")
    end,
  },
}
