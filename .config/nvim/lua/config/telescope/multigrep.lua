local pickers = require "telescope.pickers"
local finders = require "telescope.finders"
local make_entry = require "telescope.make_entry"
local conf = require "telescope.config".values

local M = {}

local multigrep = function(opts)
  opts = opts or {}
  opts.cwd = opts.cwd or vim.uv.cwd()

  local finder = finders.new_async_job {
    command_generator = function(prompt)
      if not prompt or prompt == "" then
        return nil
      end

      local parts = vim.split(prompt, "  ")
      if #parts == 0 then
        return nil
      end

      local command = {
        "rg",
        "--color=never",
        "--no-heading",
        "--with-filename",
        "--line-number",
        "--column",
        "--smart-case",
        "-e",
        parts[1],
      }

      if parts[2] then
        table.insert(command, "-g")
        table.insert(command, parts[2])
      end

      return command
    end,
    entry_maker = make_entry.gen_from_vimgrep(opts),
    cwd = opts.cwd
  }

  pickers.new(opts, {
    debounce = 100,
    prompt_title = "multigrep",
    finder = finder,
    previewer = conf.grep_previewer(opts),
  }):find()
end

M.setup = function(opts)
  vim.keymap.set("n", "<leader>fg", function() multigrep(opts) end)
end

return M
