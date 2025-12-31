return {
  {
    "ludovicchabant/vim-gutentags",
    enabled = false,
    event = { "BufReadPre", "BufNewFile" },
    init = function()
      vim.g.gutentags_ctags_tagfile = "tags"

      vim.g.gutentags_project_root = {
        ".git",
      }

      vim.g.gutentags_generate_on_write = 1
      vim.g.gutentags_generate_on_new = 1
      vim.g.gutentags_generate_on_missing = 1

      vim.g.gutentags_exclude = {
        ".git", "node_modules", "dist", "build", ".venv", "venv", "target", "__pycache__",
      }
    end,
    config = function()
      vim.opt.tags:prepend("tags")
    end,
  },
}
