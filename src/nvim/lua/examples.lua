---@diagnostic disable: missing-parameter

-- Autocommand when opening nvim to read .env file and set yarn workspace
-- ------------------------------------------------------------------------------
vim.api.nvim_create_autocmd({ "VimEnter" }, {
  pattern = { "*/some_directory/*" },
  callback = function()
    local file =
        io.open(os.getenv("HOME") .. "/development/some_directory/.env")
    if not file then
      return nil
    end
    local content = file:read "*a"
    file:close()
    local project_name = string.match(content, '.*VAR_NAME=([a-z-]*)', 1)
    vim.g.yarn_workspaces = "apps/" .. project_name .. "/"
    print("Yarn workspace: " .. project_name)
  end
})
-- ------------------------------------------------------------------------------

-- Set different variables depending on the path of the file
-- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
vim.api.nvim_create_autocmd("BufReadPost,BufNewFile",
  {
    callback = function()
      local path = vim.fn.expand("%:p") or ""

      if string.match(path, ".*some_directory.*") then
        vim.g.yarn_workspaces = "apps/some_directory/"
      end
    end
  })
-- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
