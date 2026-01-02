local function has_tag(word)
local ok, res = pcall(vim.fn.taglist, word) return ok and res and
                #res > 0 end

                           local function
                           tag_in_win(cmd_wincmd)
  local word = vim.fn.expand("<cword>")
  if not has_tag(word) then
    vim.notify("No tag: " .. word, vim.log.levels.WARN)
    return
  end

  -- check target window exists for directional moves
  if cmd_wincmd == "j" and vim.fn.winnr("j") == 0 then
    vim.notify("No window below", vim.log.levels.WARN)
    return
  end

  vim.cmd("wincmd " .. cmd_wincmd)
  vim.cmd("tag " .. vim.fn.fnameescape(word))
end

vim.keymap.set("n", "<leader>T", function() tag_in_win("p") end, { silent = true, desc = "Tag in alternate window" })
