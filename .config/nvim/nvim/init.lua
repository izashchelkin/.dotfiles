require("config.lazy")

local opt = vim.opt

opt.number = true
opt.relativenumber = true
opt.shiftwidth = 4
opt.clipboard = "unnamedplus"
opt.ignorecase = true
opt.smartcase = true
opt.guicursor = ""

vim.cmd("set cinoptions+=l1")
vim.cmd("set nowrap")

local keymap = vim.keymap

keymap.set("n", "<M-j>", "<cmd>cnext<CR>")
keymap.set("n", "<M-k>", "<cmd>cprev<CR>")
keymap.set("n", "<esc>", ":noh<CR>")
keymap.set("n", "<leader><leader>f", function() vim.lsp.buf.format() end)
keymap.set("n", "<leader>ch", "<cmd>ClangdSwitchSourceHeader<cr>");
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

keymap.set("n", "<leader>-", ":Oil<CR>")

local term_job_id;
local term_win;

keymap.set("n", "<leader>st", function()
    vim.cmd.vnew()
    term_win = vim.api.nvim_get_current_win()
    term_job_id = vim.fn.jobstart(vim.o.shell, { term = true })
    vim.cmd.wincmd("J")
    vim.api.nvim_win_set_height(0, 15)
end)

keymap.set("n", "<leader>rt", function()
    vim.api.nvim_chan_send(term_job_id, "\027[A")
    vim.api.nvim_chan_send(term_job_id, "\r")
    vim.api.nvim_win_call(term_win, function()
        vim.cmd("normal! G")
    end)
end)

vim.api.nvim_create_autocmd("TermOpen", {
    group = vim.api.nvim_create_augroup("custom-term-open", { clear = true }),
    callback = function()
        vim.opt.number = false
        vim.opt.relativenumber = false
    end
})

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
