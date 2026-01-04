---

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

---

local keymap = vim.keymap

local function feed(keys)
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(keys, true, false, true), "n", false)
end

keymap.set("n", "<leader>ch", switch_source_header, {})

keymap.set("n", "<M-j>", "<cmd>cnext<CR>")
keymap.set("n", "<M-k>", "<cmd>cprev<CR>")
keymap.set("n", "<esc>", ":noh<CR>")

keymap.set("n", "<leader><leader>f", function()
  local view = vim.fn.winsaveview()
  vim.lsp.buf.format({ async = false, timeout_ms = 3000 })
  vim.fn.winrestview(view)
end, { desc = "Format buffer with LSP" })

keymap.set("n", "<leader>x", ":.lua<CR>")
keymap.set("n", "<leader><leader>x", "<cmd>source %<CR>")
keymap.set("v", "<leader>x", ":lua<CR>")

-- half-page moves + center
keymap.set("n", "<C-d>", function() feed("<C-d>zz") end, { silent = true })
keymap.set("n", "<C-u>", function() feed("<C-u>zz") end, { silent = true })

-- search next/prev + center
keymap.set("n", "n", function() feed("nzz") end, { silent = true })
keymap.set("n", "N", function() feed("Nzz") end, { silent = true })

-- full-page moves + center
keymap.set("n", "<C-f>", function() feed("<C-f>zz") end, { silent = true })
keymap.set("n", "<C-b>", function() feed("<C-b>zz") end, { silent = true })

-- paragraph moves + center
keymap.set("n", "{", function() feed("{zz") end, { silent = true })
keymap.set("n", "}", function() feed("}zz") end, { silent = true })

vim.keymap.set('n', '*', function()
  local w = vim.fn.expand('<cword>')
  vim.fn.setreg('/', [[\V\<]] .. vim.fn.escape(w, [[\]]) .. [[\>]])
  vim.opt.hlsearch = true
end, { silent = true })

keymap.set("n", "<leader>-", ":Oil<CR>")

