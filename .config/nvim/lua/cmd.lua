vim.api.nvim_create_user_command('CloseHidden', function()
  for _, b in ipairs(vim.api.nvim_list_bufs()) do
    if vim.fn.buflisted(b) == 1 and vim.fn.bufwinnr(b) == -1 then
      vim.api.nvim_buf_delete(b, {})
    end
  end
end, { desc = 'Schließt alle nicht sichtbaren Buffer' })
