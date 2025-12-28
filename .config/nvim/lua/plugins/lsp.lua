return {
  {
    "neovim/nvim-lspconfig",
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
        lua_ls = {},
        clangd = {
          root_dir = function(fname)
            return vim.fs.root(fname, {
              "compile_commands.json",
              "compile_flags.txt",
              ".git",
              "Makefile",
              "configure.ac",
              "configure.in",
              "config.h.in",
              "meson.build",
              "meson_options.txt",
              "build.ninja",
            })
          end,
          cmd = {
            "clangd",
            "--pretty",
            "--background-index",
            "--clang-tidy",
            "--header-insertion=iwyu",
            "--completion-style=detailed",
            "--fallback-style=none",
          },
          init_options = {
            usePlaceholders = true,
            completeUnimported = true,
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
    end,
  },
}
