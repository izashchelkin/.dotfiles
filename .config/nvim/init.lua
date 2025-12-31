require("config.lazy")

local opt = vim.opt

opt.number = true
opt.relativenumber = true
opt.shiftwidth = 4
opt.clipboard = "unnamedplus"
opt.ignorecase = true
opt.smartcase = true
opt.guicursor = ""

vim.opt.shellpipe = ">%s 2>&1"
vim.opt.shellredir = ">%s 2>&1"

vim.opt.grepprg = "rg --vimgrep --smart-case"
vim.opt.grepformat = "%f:%l:%c:%m"

vim.cmd("set cinoptions+=l1")
vim.cmd("set nowrap")

local function switch_source_header()
  local file = vim.api.nvim_buf_get_name(0)
  if file == "" then return end

  local dir  = vim.fn.fnamemodify(file, ":h")
  local base = vim.fn.fnamemodify(file, ":t:r")
  local ext  = vim.fn.fnamemodify(file, ":e"):lower()

  local headers = { "h", "hh", "hpp", "hxx", "inl" }
  local sources = { "c", "cc", "cpp", "cxx", "m", "mm" }

  local candidates
  if vim.tbl_contains(headers, ext) then
    candidates = sources
  else
    candidates = headers
  end

  for _, e in ipairs(candidates) do
    local cand = dir .. "/" .. base .. "." .. e
    if vim.fn.filereadable(cand) == 1 then
      vim.cmd.edit(vim.fn.fnameescape(cand))
      return
    end
  end

  vim.notify(("No counterpart found for %s.%s in %s"):format(base, ext, dir), vim.log.levels.WARN)
end
vim.keymap.set("n", "<leader>ch", switch_source_header, { desc = "Switch source/header (no LSP)" })

local keymap = vim.keymap

keymap.set("n", "<M-j>", "<cmd>cnext<CR>")
keymap.set("n", "<M-k>", "<cmd>cprev<CR>")
keymap.set("n", "<esc>", ":noh<CR>")

keymap.set("n", "<leader><leader>f", function()
  local view = vim.fn.winsaveview()
  vim.cmd("%!clang-format")
  vim.fn.winrestview(view)
end, { desc = "Format buffer with clang-format" })

-- vim.keymap.set("v", "<leader><leader>f", function()
--   local view = vim.fn.winsaveview()
--   vim.cmd("'<,'>!clang-format")
--   vim.fn.winrestview(view)
-- end, { desc = "Format selection with clang-format" })

-- keymap.set("n", "<leader>ch", "<cmd>ClangdSwitchSourceHeader<cr>");
keymap.set("n", "<leader>x", ":.lua<CR>")

-- keymap.set("n", "<leader>f", ":lua vim.diagnostic.open_float()<CR>")

keymap.set("n", "<leader><leader>x", "<cmd>source %<CR>")
keymap.set("v", "<leader>x", ":lua<CR>")

keymap.set("n", "<C-d>", "<C-d>zz")
keymap.set("n", "<C-u>", "<C-u>zz")
keymap.set("n", "n", "nzz")
keymap.set("n", "N", "Nzz")
keymap.set("n", "{", "{zz")
keymap.set("n", "}", "}zz")

keymap.set("n", "*", "*N")
-- keymap.set("v", "*", "*N") TODO: how to do this?

keymap.set("n", "<leader>-", ":Oil<CR>")

vim.lsp.set_log_level("off")
-- vim.lsp.set_log_level("debug")

vim.api.nvim_create_autocmd({ "InsertLeave", "TextChanged" }, {
  pattern = "*",
  callback = function(ev)
    local ft = vim.bo[ev.buf].filetype

    local blacklist = {
      oil = true,
      terminal = true,
      ["neo-tree"] = true,
      ["TelescopePrompt"] = true,
    }

    if blacklist[ft] then
      return
    end

    vim.cmd("silent! wall")
  end,
  nested = true,
})

-- local term_job_id;
-- local term_win;
--
-- keymap.set("n", "<leader>st", function()
--   vim.cmd.vnew()
--   term_win = vim.api.nvim_get_current_win()
--   term_job_id = vim.fn.jobstart(vim.o.shell, { term = true })
--   vim.cmd.wincmd("J")
--   vim.api.nvim_win_set_height(0, 15)
-- end)
--
-- keymap.set("n", "<leader>rt", function()
--   vim.api.nvim_chan_send(term_job_id, "\027[A")
--   vim.api.nvim_chan_send(term_job_id, "\r")
--   vim.api.nvim_win_call(term_win, function()
--     vim.cmd("normal! G")
--   end)
-- end)
--
-- vim.api.nvim_create_autocmd("TermOpen", {
--   group = vim.api.nvim_create_augroup("custom-term-open", { clear = true }),
--   callback = function()
--     vim.opt.number = false
--     vim.opt.relativenumber = false
--   end
-- })

vim.api.nvim_create_autocmd("TextYankPost", {
  group = vim.api.nvim_create_augroup("highlight-yank", { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end
})

-- https://github.com/justinmk/config/blob/master/.config/nvim/lua/my/keymaps.lua
--
-- -- g?: Web search
-- vim.keymap.set('n', 'g??', function()
--   vim.ui.open(('https://google.com/search?q=%s'):format(vim.fn.expand('<cword>')))
-- end)
-- vim.keymap.set('x', 'g??', function()
--   vim.ui.open(('https://google.com/search?q=%s'):format(vim.trim(table.concat(
--     vim.fn.getregion(vim.fn.getpos('.'), vim.fn.getpos('v'), { type=vim.fn.mode() }), ' '))))
--   vim.api.nvim_input('<esc>')
-- end)

require "buildutils"
