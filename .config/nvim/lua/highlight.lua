if false then
  vim.api.nvim_set_hl(0, "MyFnMacro", { link = "Macro" })

  vim.api.nvim_create_autocmd("FileType", {
    pattern = { "c", "cpp" },
    callback = function(args)
      local buf = args.buf
      local old = vim.b[buf].fnmacro_match_id
      if old then pcall(vim.fn.matchdelete, old) end

      -- highlight ONLY the macro name, but only if it's followed by optional spaces + '('
      vim.b[buf].fnmacro_match_id =
        vim.fn.matchadd("MyFnMacro", [[\v<\u[A-Z0-9_]*>\ze\s*\(]])
    end,
  })
end

local lemonColor="#fdff00"
local searchStyle = {
  fg = lemonColor,
  bg = "NONE",
  underline = true,
  bold = true,
}

vim.api.nvim_set_hl(0, "Search",    searchStyle)
vim.api.nvim_set_hl(0, "IncSearch", searchStyle)
vim.api.nvim_set_hl(0, "CurSearch", searchStyle)

vim.api.nvim_create_autocmd("ColorScheme", {
  callback = function()
    vim.api.nvim_set_hl(0, "Search",    searchStyle)
    vim.api.nvim_set_hl(0, "IncSearch", searchStyle)
    vim.api.nvim_set_hl(0, "CurSearch", searchStyle)
  end,
})
