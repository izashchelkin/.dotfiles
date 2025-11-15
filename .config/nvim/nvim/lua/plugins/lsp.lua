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
            { path = "${3rd}/luv/library", words = { "vim%.uv" } }
          }
        }
      }
    },
    opts = {
      servers = {
        -- ruff = {},
        lua_ls = {},
        clangd = {
          root_dir = function(fname)
            return require("lspconfig.util").root_pattern(
              "compile_commands.json",
              "compile_flags.txt",
              ".git",
              "Makefile",
              "configure.ac",
              "configure.in",
              "config.h.in",
              "meson.build",
              "meson_options.txt",
              "build.ninja"
            )(fname)
          end,
          cmd = {
            -- "/home/izashchelkin/scylladev/scylladb/tools/toolchain/dbuild",
            "clangd",
            "--pretty",
            "--background-index",
            "--clang-tidy",
            -- "--header-insertion=never",
            "--header-insertion=iwyu",
            "--completion-style=detailed",
            "--fallback-style=none",
            -- "--function-arg-placeholders",
          },
          init_options = {
            usePlaceholders = true,
            completeUnimported = true,
            clangdFileStatus = true,
          },
        },
      }
    },
    config = function(_, opts)
      local lspconfig = require("lspconfig")
      for server, config in pairs(opts.servers) do
        config.capabilities = require "blink.cmp".get_lsp_capabilities(config.capabilities)
        lspconfig[server].setup(config)
      end
    end,
  }
}
