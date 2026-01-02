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
keymap.set("n", "<C-f>", "<C-f>zz")
keymap.set("n", "<C-b>", "<C-b>zz")
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

--
-- QUICKFIX BUFFER STUFF BEGIN
--

local diag_qf_augroup = vim.api.nvim_create_augroup("DiagnosticQuickfix", { clear = true })

-- Rebuild quickfix list only when diagnostics actually change
vim.api.nvim_create_autocmd({ "DiagnosticChanged", "BufWritePost" }, {
    group = diag_qf_augroup,
    callback = function()
        vim.diagnostic.setqflist({ open = false }) -- all buffers
    end,
})

local function qf_jump_to_first_for_current_buf()
    -- only if quickfix window is open
    local qf_win
    for _, win in ipairs(vim.api.nvim_list_wins()) do
        if vim.bo[vim.api.nvim_win_get_buf(win)].buftype == "quickfix" then
            qf_win = win
            break
        end
    end
    if not qf_win then return end

    local curbuf = vim.api.nvim_get_current_buf()
    local qfl = vim.fn.getqflist()
    if not qfl or #qfl == 0 then return end

    local target_idx
    for i, item in ipairs(qfl) do
        if item.valid == 1 and item.bufnr == curbuf then
            target_idx = i
            break
        end
    end
    if not target_idx then return end

    -- move quickfix "current entry" without rebuilding
    vim.fn.setqflist({}, "r", { idx = target_idx })

    -- scroll quickfix window so it's visible
    vim.api.nvim_win_call(qf_win, function()
        vim.cmd("normal! zz")
    end)
end

-- When changing focus, jump within the existing list
vim.api.nvim_create_autocmd({ "BufEnter", "WinEnter" }, {
    group = diag_qf_augroup,
    callback = qf_jump_to_first_for_current_buf,
})

---
-- QUICKFIX BUFFER STUFF END
--

--
-- FILE TYPES BEGIN
--

vim.filetype.add({
    extension = {
        hlsl  = "hlsl",
        hlsli = "hlsl",
        fx    = "hlsl",
        fxh   = "hlsl",
    },
})

--
-- FILE TYPES END
--

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
require "macrohighlight"
