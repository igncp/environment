local M = {}

-- https://stackoverflow.com/a/69142336/3244654
function M.t(str) return vim.api.nvim_replace_termcodes(str, true, true, true) end

function M.file_exists(name)
  local f = io.open(name, "r")
  if f ~= nil then
    io.close(f)
    return true
  else
    return false
  end
end

function M.get_config_file_path(name)
  return os.getenv("HOME") .. '/development/environment/project/.config/' .. name
end

function M.has_config(name)
  local config_path = M.get_config_file_path(name)
  return M.file_exists(config_path)
end

return M
