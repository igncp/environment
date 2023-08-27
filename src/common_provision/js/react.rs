use crate::base::Context;

pub fn setup_js_react(context: &mut Context) {
    context.home_append(
        ".vim/lua/extra_beginning.lua",
        r###"
function OpenCorrespondingReactSCSS(search)
  local word_to_search = ""
  if search then
    word_to_search = vim.fn.expand('<cword>')
  end

  local file_name = vim.fn.expand('%:t')
  local file_name_escaped = string.gsub(file_name, '%-', '%%-')

  local new_file_path = ""

  local function get_file_path()
    local full_path = vim.fn.expand('%:p')
    return string.gsub(full_path, file_name_escaped, '')
  end

  local file_name_base = ""

  if string.match(file_name, '.*%.tsx') then
    file_name_base = string.gsub(file_name, '.tsx', '')
    new_file_path = get_file_path() .. file_name_base .. '.module.scss'
  elseif string.match(file_name, '.*%.module.scss') then
    file_name_base = string.gsub(file_name, '.module.scss', '')
    new_file_path = get_file_path() .. file_name_base .. '.tsx'
  end

  if new_file_path ~= "" then
    vim.cmd('tab drop ' .. new_file_path)
  end

  if word_to_search ~= "" then
    -- Move left first in case it was already in the word
    vim.cmd('normal! h')
    local function search_item()
      vim.cmd('normal! /' .. word_to_search .. '\r')
    end

    if pcall(search_item) then
      -- Do nothing
    elseif string.match(file_name, '.*%.tsx') then
      vim.cmd('normal! Go\r.' .. word_to_search .. ' {\r}')
      vim.cmd('normal! O  ')
    end
  end
end

vim.api.nvim_set_keymap("n", "<leader>mi", "<cmd>lua OpenCorrespondingReactSCSS(true)<CR>", { noremap = true })
vim.api.nvim_set_keymap("n", "<leader>me", "<cmd>lua OpenCorrespondingReactSCSS(false)<CR>", { noremap = true })
"###,
    );
}
