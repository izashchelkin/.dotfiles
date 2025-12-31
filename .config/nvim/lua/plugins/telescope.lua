return {
  {
    "nvim-telescope/telescope.nvim",
    branch = 'master',
    lazy = false,
    dependencies = {
      "nvim-lua/plenary.nvim",
      { "nvim-telescope/telescope-fzf-native.nvim", build = 'cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release --target install' }
    },
    config = function()
      require("telescope").setup {
        pickers = {
          find_files = {
            -- theme = "ivy",
            hidden = true,
          }
        },
        extensions = {
          fzf = {}
        }
      }

      require("telescope").load_extension("fzf")

      vim.keymap.set("n", "<leader>fh", require "telescope.builtin".help_tags)
      vim.keymap.set("n", "<leader>fd", require "telescope.builtin".find_files)
      vim.keymap.set("n", "<leader>en", function()
        require("telescope.builtin").find_files {
          cwd = vim.fn.stdpath("config")
        }
      end)
      vim.keymap.set("n", "<leader>ep", function()
        require("telescope.builtin").find_files {
          cwd = vim.fs.joinpath(vim.fn.stdpath "data", "lazy")
        }
      end)

      require "config.telescope.multigrep".setup()
      -- require "config.telescope.multigrep".setup(require "telescope.themes".get_ivy())
    end
  }
}
