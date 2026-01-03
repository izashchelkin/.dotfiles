
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

if false then

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


local diag_qf_augroup = vim.api.nvim_create_augroup("DiagnosticQuickfix", { clear = true })

-- When changing focus, jump within the existing list
vim.api.nvim_create_autocmd({ "BufEnter", "WinEnter" }, {
    group = diag_qf_augroup,
    callback = qf_jump_to_first_for_current_buf,
})

-- Rebuild quickfix list only when diagnostics actually change
vim.api.nvim_create_autocmd({ "DiagnosticChanged", "BufWritePost" }, {
    group = diag_qf_augroup,
    callback = function()
        vim.diagnostic.setqflist({ open = false }) -- all buffers
    end,
})

end
