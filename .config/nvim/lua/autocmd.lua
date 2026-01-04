
--- Yank highlighter
vim.api.nvim_create_autocmd("TextYankPost", {
  group = vim.api.nvim_create_augroup("highlight-yank", { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end
})

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

