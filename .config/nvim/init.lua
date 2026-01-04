require("config.lazy")

local opt = vim.opt

opt.number = true
opt.relativenumber = true
opt.shiftwidth = 4
opt.clipboard = "unnamedplus"
opt.ignorecase = true
opt.smartcase = true
opt.guicursor = ""
opt.cursorline = true
opt.shellpipe = ">%s 2>&1"
opt.shellredir = ">%s 2>&1"
opt.grepprg = "rg --vimgrep --smart-case"
opt.grepformat = "%f:%l:%c:%m"

vim.o.splitbelow = true
vim.o.splitright = true

vim.api.nvim_create_autocmd("FileType", {
  pattern = "qf",
  callback = function()
    vim.cmd("botright resize 10")
  end,
})

local cmd = vim.cmd

cmd("set cinoptions+=l1")
cmd("set nowrap")

require "filetype"
require "autocmd"
require "keymap"
require "buildutils"
require "highlight"
require "navigation"
