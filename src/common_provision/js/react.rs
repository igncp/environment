use crate::base::Context;

pub fn setup_js_react(context: &mut Context) {
    context.home_append(
        ".vim/lua/extra_beginning.lua",
        r###"
function OpenCorrespondingReactSCSS(search)
  local word_to_search = ""
  if search then
    word_to_search = vim.fn.expand('<cword>')
    if word_to_search == "styles" then
      vim.cmd(t('normal! f.l'))
      word_to_search = vim.fn.expand('<cword>')
    end
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
      vim.cmd('normal! /\\<' .. word_to_search .. '\\>\r')
    end

    if pcall(search_item) then
      -- Do nothing
    elseif string.match(file_name, '.*%.tsx') then
      vim.cmd('normal! Go\r.' .. word_to_search .. ' {\r}')
      vim.cmd('normal! O  ')
    end
  end
end

vim.api.nvim_set_keymap("n", "<leader>mo", "<cmd>lua OpenCorrespondingReactSCSS(true)<CR>", { noremap = true })
vim.api.nvim_set_keymap("n", "<leader>me", "<cmd>lua OpenCorrespondingReactSCSS(false)<CR>", { noremap = true })

function AddStylesImport(is_common)
  local file_name = vim.fn.expand('%:t')

  if string.match(file_name, '.*%.tsx') then
    local file_name_base = string.gsub(file_name, '.tsx', '')
    local function search_item()
      if is_common then
        vim.cmd('normal! /* as commonStyles\r')
      else
        vim.cmd('normal! /* as styles\r')
      end
    end
    if pcall(search_item) then
      -- Do nothing if the import already exists
    elseif is_common then
      vim.cmd('normal! ggOimport * as commonStyles from \'~/styles/common.module.scss\';\r')
    else
      vim.cmd('normal! ggOimport * as styles from \'./' .. file_name_base .. '.module.scss\';\r')
    end
    vim.cmd('normal! ``')
  elseif string.match(file_name, '.*%.module.scss') then
    local function search_item()
      vim.cmd('normal! /sass.scss\r')
    end
    if pcall(search_item) then
      -- Do nothing if the import already exists
    else
      vim.cmd('normal! ggO@import "src/styles/sass.scss";\r')
    end
    vim.cmd('normal! ``')
  end
end

vim.api.nvim_set_keymap("n", "<leader>mi", "<cmd>lua AddStylesImport(false)<CR>", { noremap = true })
vim.api.nvim_set_keymap("n", "<leader>mI", "<cmd>lua AddStylesImport(true)<CR>", { noremap = true })
vim.api.nvim_set_keymap("n", "<leader>mr", ":CocCommand eslint.executeAutofix<CR>", { noremap = true })
vim.api.nvim_set_keymap("n", "<leader>mj", "vi}S]%a.join(' ')<c-c>F]i, ", { noremap = false })
"###,
    );
}
