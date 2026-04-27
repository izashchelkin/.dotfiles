
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

-- vim.api.nvim_create_autocmd("BufWinEnter", {
--   pattern = { "*.cc", "*.c", "*.cpp", "*.h", "*.hpp" },
--   callback = function()
--     vim.cmd("LspStart clangd")
--   end,
-- })
--
-- vim.api.nvim_create_autocmd("BufWinLeave", {
--   pattern = { "*.cc", "*.c", "*.cpp", "*.h", "*.hpp" },
--   callback = function(args)
--     local bufnr = args.buf
--     vim.schedule(function()
--       if vim.api.nvim_buf_is_valid(bufnr) and #vim.fn.win_findbuf(bufnr) == 0 then
--         for _, client in ipairs(vim.lsp.get_clients({ bufnr = bufnr, name = "clangd" })) do
--           vim.lsp.buf_detach_client(bufnr, client.id)
--         end
--       end
--     end)
--   end,
-- })
--
-- vim.api.nvim_create_autocmd("FocusLost", {
--   pattern = "*",
--   callback = function()
--     vim.cmd("silent! LspStop clangd")
--   end,
-- })
--
-- vim.api.nvim_create_autocmd("FocusGained", {
--   pattern = "*",
--   callback = function()
--     local visible_bufs = {}
--     
--     for _, win in ipairs(vim.api.nvim_list_wins()) do
--       visible_bufs[vim.api.nvim_win_get_buf(win)] = true
--     end
--
--     for bufnr, _ in pairs(visible_bufs) do
--       if vim.api.nvim_buf_is_valid(bufnr) then
--         local ft = vim.bo[bufnr].filetype
--         if ft == "c" or ft == "cpp" or ft == "objc" or ft == "objcpp" then
--           vim.api.nvim_buf_call(bufnr, function()
--             vim.cmd("silent! LspStart clangd")
--           end)
--         end
--       end
--     end
--   end,
-- })

