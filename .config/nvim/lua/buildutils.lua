-- Simple build runner for Neovim
-- Commands:
--   :Build [<cmake-build-dir> <target>]   (2 args = set+run, 0 args = rerun last)
--   :BuildClear                           (clear build output buffer)
--   :BuildQf                              (parse errors into quickfix)
-- Keys:
--   F5 = Build (repeat last), F6 = BuildQf
--
-- Notes:
-- - Uses one persistent "Build Output" buffer (listed, so you can :ls / :b it).
-- - Does NOT steal focus. If the build buffer isn't visible anywhere, it opens it
--   in a split, then returns you to your original window.

local M = {}

local sysname = vim.loop.os_uname().sysname
local is_windows = sysname:match("Windows") ~= nil

-- Persist last args across reloads for the current Neovim session
M.last_dir = vim.g.build_last_dir
M.last_target = vim.g.build_last_target

-- Errorformat:
-- - MSVC: match "file(line): ..." (works with "error C1234:" without special handling)
-- - Clang/GCC: match "file:line:col: ..." and "file:line: ..."
local efm_msvc = table.concat({
  [[%f(%l,%c): %m]],
  [[%f(%l): %m]],
  [[%f(%l,%c)\ : %m]],
  [[%f(%l)\ : %m]],
  [[%*[^ ] : %m]], -- LINK : ... or tool : ...
  [[%*[^ ]: %m]],
}, ",")

local efm_clang = table.concat({
  [[%f:%l:%c: %m]],
  [[%f:%l: %m]],
}, ",")

local function normalize_lines(lines)
  -- If you ever copied quickfix display back into the buffer, it can prefix lines with "|| ".
  -- Remove that so errorformat matches.
  local out = {}
  for _, l in ipairs(lines) do
    out[#out + 1] = (l:gsub("^%s*||%s*", ""))
  end
  return out
end

local function filter_errors(lines)
  local out = {}
  if is_windows then
    for _, l in ipairs(lines) do
      if l:find(" error ", 1, true) or l:find("fatal error", 1, true) then
        out[#out + 1] = l
      end
    end
  else
    for _, l in ipairs(lines) do
      if l:find(": error:", 1, true) or l:find(": fatal error:", 1, true) then
        out[#out + 1] = l
      end
    end
  end
  return out
end

local function get_build_buf()
  -- Reuse saved buffer number if possible
  local b = vim.g.build_output_bufnr
  if type(b) == "number" and vim.api.nvim_buf_is_valid(b) then
    return b
  end

  -- Otherwise create it (listed=true so it shows in :ls)
  b = vim.api.nvim_create_buf(true, true)
  vim.bo[b].buftype = "nofile"
  vim.bo[b].bufhidden = "hide"
  vim.bo[b].swapfile = false
  vim.bo[b].modifiable = true
  vim.bo[b].filetype = "buildlog"
  vim.api.nvim_buf_set_name(b, "Build Output")

  vim.g.build_output_bufnr = b
  return b
end

local function ensure_buf_visible(bufnr)
  -- If it's already in a window somewhere, do nothing
  if vim.fn.bufwinnr(bufnr) ~= -1 then
    return
  end

  -- Open it in a split but don't steal focus
  -- local curwin = vim.api.nvim_get_current_win()
  -- vim.cmd("botright split")
  -- vim.api.nvim_win_set_buf(0, bufnr)
  -- vim.api.nvim_set_current_win(curwin)
end

local function clear_buf(bufnr)
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, {})
end

local function append_lines(bufnr, lines)
  if not lines or #lines == 0 then return end
  if lines[#lines] == "" then table.remove(lines, #lines) end
  if #lines == 0 then return end

  vim.schedule(function()
    if vim.api.nvim_buf_is_valid(bufnr) then
      vim.api.nvim_buf_set_lines(bufnr, -1, -1, false, lines)
    end
  end)
end

local function set_qf_from_buf(bufnr)
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  lines = normalize_lines(lines)
  lines = filter_errors(lines)

  local efm = is_windows and efm_msvc or efm_clang
  local title = is_windows and "Build (MSVC) errors" or "Build (Clang/GCC) errors"

  vim.fn.setqflist({}, " ", { title = title, lines = lines, efm = efm })

  if #vim.fn.getqflist() > 0 then
    vim.cmd("copen")
  else
    vim.notify("BuildQf: no errors parsed.")
  end
end

-- Re-source safe: delete commands if they exist
pcall(vim.api.nvim_del_user_command, "Build")
pcall(vim.api.nvim_del_user_command, "BuildClear")
pcall(vim.api.nvim_del_user_command, "BuildQf")

vim.api.nvim_create_user_command("Build", function(opts)
  local args = opts.fargs
  local dir, target

  if #args == 0 then
    dir, target = M.last_dir, M.last_target
    if not dir or not target then
      vim.notify("Usage: :Build <cmake-build-dir> <target>  (or :Build to repeat last)", vim.log.levels.ERROR)
      return
    end
  elseif #args == 2 then
    dir, target = args[1], args[2]
    M.last_dir, M.last_target = dir, target
    vim.g.build_last_dir, vim.g.build_last_target = dir, target
  else
    vim.notify("Usage: :Build <cmake-build-dir> <target>  (or :Build to repeat last)", vim.log.levels.ERROR)
    return
  end

  local bufnr = get_build_buf()
  ensure_buf_visible(bufnr)
  clear_buf(bufnr)
  append_lines(bufnr, { ("== Build: dir=%s target=%s =="):format(dir, target) })

  vim.fn.jobstart({ "cmake", "--build", dir, "--target", target }, {
    stdout_buffered = false,
    stderr_buffered = false,
    on_stdout = function(_, data) append_lines(bufnr, data) end,
    on_stderr = function(_, data) append_lines(bufnr, data) end,
    on_exit = function(_, code)
      vim.notify(("== Build finished (exit %d) =="):format(code), vim.log.levels.INFO)
    end,
  })
end, { nargs = "*", complete = "file" })

vim.api.nvim_create_user_command("BuildClear", function()
  clear_buf(get_build_buf())
end, {})

vim.api.nvim_create_user_command("BuildQf", function()
  set_qf_from_buf(get_build_buf())
end, {})

-- Keys
vim.keymap.set("n", "<F5>", function()
  if vim.bo.modified then vim.cmd("write") end
  vim.cmd("Build")
end, { silent = true })

vim.keymap.set("n", "<F6>", function()
  vim.cmd("BuildQf")
end, { silent = true })
