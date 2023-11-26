-- https://github.com/folke/lazy.nvim
-- Press `:Lazy` to open the popup, and `?` to see the help

---@diagnostic disable: missing-parameter

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git", "--branch=stable", -- latest stable release
    lazypath
  })
end
vim.opt.rtp:prepend(lazypath)

-- This variable is populated with the packages
local nvim_plugins = {
}

require("lazy").setup(nvim_plugins)

require('gitsigns').setup()

local function try_marks() require('marks').setup({ default_mappings = true }) end

pcall(try_marks)

vim.api.nvim_set_keymap("i", "<C-_>", "<Plug>(copilot-next)",
  { silent = true, nowait = true })
vim.api.nvim_set_keymap("i", "<C-\\>", "<Plug>(copilot-previous)",
  { silent = true, nowait = true })

-- Undo tree
vim.api.nvim_set_keymap("n", "<leader>mm", ":UndotreeShow<cr><c-w><left>",
  { noremap = true })

-- fzf maps
vim.api.nvim_set_keymap("n", "<leader>ja", ":Ag!<cr>", { noremap = true })
vim.api.nvim_set_keymap("n", "<leader>jb", ":Buffers!<cr>", { noremap = true })
vim.api.nvim_set_keymap("n", "<leader>jc", ":Commands!<cr>", { noremap = true })
vim.api.nvim_set_keymap("n", "<leader>jg", ":GFiles!<cr>", { noremap = true })
vim.api.nvim_set_keymap("n", "<leader>jh", ":History!<cr>", { noremap = true })
vim.api.nvim_set_keymap("n", "<leader>jj", ":BLines!<cr>", { noremap = true })
vim.api.nvim_set_keymap("n", "<leader>jl", ":Lines!<cr>", { noremap = true })
vim.api.nvim_set_keymap("n", "<leader>jm", ":Marks!<cr>", { noremap = true })
vim.api.nvim_set_keymap("n", "<leader>jM", ":Maps!<cr>", { noremap = true })
vim.api.nvim_set_keymap("n", "<leader>jt", ":Tags!<cr>", { noremap = true })
vim.api.nvim_set_keymap("n", "<leader>jw", ":Windows!<cr>", { noremap = true })
vim.api.nvim_set_keymap("n", "<leader>jf", ":Filetypes!<cr>", { noremap = true })
vim.api.nvim_set_keymap("n", "<leader>je", ":AnsiEsc!<cr>", { noremap = true })

-- Snippets display
vim.api.nvim_set_keymap("n", "<leader>ms",
  ":CocCommand snippets.openSnippetFiles<cr>",
  { noremap = true })

-- Vista
vim.g.vista_default_executive = 'coc'
vim.g.vista_sidebar_width = 100

-- limelight
vim.g.limelight_conceal_ctermfg = 'LightGray'
vim.g.limelight_bop = '^'
vim.g.limelight_eop = '$'
vim.api.nvim_set_keymap("n", "<leader>zl", ":Limelight!!<cr>", { noremap = true })
vim.api.nvim_set_keymap("n", "<leader>zL",
  ":let g:limelight_paragraph_span = <left><right>",
  { noremap = true })

-- auto-pairs
vim.g.AutoPairsMultilineClose = 0

-- incsearch.vim
vim.api.nvim_set_keymap("n", "/", "<Plug>(incsearch-forward)", {})
vim.api.nvim_set_keymap("n", "?", "<Plug>(incsearch-backward)", {})
vim.api.nvim_set_keymap("n", "g/", "<Plug>(incsearch-stay)", {})

-- nerdcommenter
vim.g.NERDSpaceDelims = 1
vim.api.nvim_set_keymap("n", "<leader>cp", "mavip:call nerdcommenter#Comment('x', 'AlignLeft')<cr>`a:delm a<cr>ll",
  { noremap = true })
vim.api.nvim_set_keymap("n", "<leader>cP", "mavip:call nerdcommenter#Comment('x', 'Uncomment')<cr>`a:delm a<cr>hh",
  { noremap = true })

-- vim fugitive
vim.cmd('set diffopt+=vertical')
vim.cmd('command Gb Git blame')

-- vim-json
vim.g.vim_json_syntax_conceal = 0

-- save file shortcuts
vim.api.nvim_set_keymap("n", "<leader>ks",
  ':silent exec "!mkdir -p <c-R>=expand("%:p:h")<cr>"<cr>:w<cr>:silent exec ":CtrlPClearAllCaches"<cr>',
  { noremap = true })

-- markdown
vim.g.vim_markdown_auto_insert_bullets = 0
vim.g.vim_markdown_new_list_item_indent = 0
vim.g.vim_markdown_conceal = 0
vim.g.tex_conceal = ""
vim.g.vim_markdown_math = 1
vim.g.vim_markdown_folding_disabled = 1
vim.cmd 'autocmd Filetype markdown set conceallevel=0'

-- markdown preview
vim.g.mkdp_port = 9050
vim.g.mkdp_echo_preview_url = 1

-- format json
vim.cmd 'command! -range -nargs=0 -bar JsonTool <line1>,<line2>!python -m json.tool'
vim.api.nvim_set_keymap("n", "<leader>kz", ':JsonTool<cr>', { noremap = true })
vim.api.nvim_set_keymap("v", "<leader>kz", ":'<,'>JsonTool<cr>",
  { noremap = true })

vim.g.peekaboo_window = 'vert bo new'

vim.g.gruvbox_contrast_dark = 'hard'

function Select_indent(around)
  local line = vim.fn.line('.')
  if line == nil then
    return
  end
  local start_indent = vim.fn.indent(line)
  local prev_line = vim.fn.line('.') - 1
  local blank_line_pattern = '^%s*$'

  while prev_line > 0 and vim.fn.indent(prev_line) >= start_indent do
    ---@diagnostic disable-next-line: param-type-mismatch
    if string.match(vim.fn.getline(prev_line), blank_line_pattern) then
      break
    end
    vim.cmd('-')
    prev_line = vim.fn.line('.') - 1
  end

  if around then
    vim.cmd('-')
  end

  vim.cmd('normal! 0V')

  local next_line = vim.fn.line('.') + 1
  local last_line = vim.fn.line('$')
  while next_line <= last_line and vim.fn.indent(next_line) >= start_indent do
    ---@diagnostic disable-next-line: param-type-mismatch
    if string.match(vim.fn.getline(next_line), blank_line_pattern) then
      break
    end
    vim.cmd('+')
    next_line = vim.fn.line('.') + 1
  end
  if around then
    vim.cmd('+')
  end
end

for _, mode in ipairs({ 'x', 'o' }) do
  vim.api.nvim_set_keymap(mode, 'ii', ':<c-u>lua Select_indent()<cr>',
    { noremap = true, silent = true })
  vim.api.nvim_set_keymap(mode, 'ai', ':<c-u>lua Select_indent(true)<cr>',
    { noremap = true, silent = true })
end

local M = require("common")

local theme_path = M.get_config_file_path('vim-theme')

if M.file_exists(theme_path) then
  local file = io.open(theme_path, "rb")
  if not file then
    return nil
  end
  local content = file:read "*a"
  file:close()
  vim.cmd("colorscheme " .. content)
end

local custom_path = os.getenv("HOME") ..
    '/development/environment/project/.vim-custom.lua'

if M.file_exists(custom_path) then
  dofile(custom_path)
end

vim.api.nvim_set_keymap("n", "<c-f>", ":call SpecialMaps()<cr>",
  { noremap = true })
vim.api.nvim_set_keymap("i", "<c-f>", "<c-c>:call SpecialMaps()<cr>",
  { noremap = true })

vim.api.nvim_set_keymap("i", "<c-l>",
  "<C-r>=coc#rpc#request('doKeymap', ['snippets-expand-jump',''])<CR>",
  {})
vim.api.nvim_set_keymap("s", "<c-l>",
  "<C-r>=coc#rpc#request('doKeymap', ['snippets-expand-jump',''])<CR>",
  {})

vim.api.nvim_set_keymap("n", "<leader>da", "<Plug>(coc-codeaction-cursor)",
  { silent = true, nowait = true })
vim.api.nvim_set_keymap("v", "<leader>da", "<Plug>(coc-codeaction-selected)",
  { silent = true, nowait = true })

-- This is due to the screen not cleaned when dismissing a suggestion
if M.has_config("copilot") then
  vim.cmd([[
hi CopilotSuggestion guifg=#ff8700 ctermfg=208

function! CustomDismiss() abort
  unlet! b:_copilot_suggestion b:_copilot_completion
  call copilot#Clear()
  redraw!
  echo "Dismissed"
  return ''
endfunction
]])

  for _, mode in ipairs({ 'i', 'n' }) do
    vim.api.nvim_set_keymap(mode, "<C-]>", 'CustomDismiss() . "<C-]>"',
      { silent = true, nowait = true, expr = true, script = true })
  end
end

vim.api.nvim_create_autocmd("BufWritePost",
  {
    pattern = "*.nix",
    callback = function()
      if vim.g.environment_format_nix ~= 0 then
        vim.cmd("silent !alejandra " .. vim.fn.expand("%"))
        vim.cmd("e!")
      end
    end
  })

vim.api.nvim_create_autocmd("BufWritePost",
  {
    pattern = "*.sh",
    callback = function()
      if vim.g.environment_format_sh ~= 0 then
        vim.cmd("silent !shfmt -i 2 -w " .. vim.fn.expand("%"))
        vim.cmd("e!")
      end
    end
  })

function SaveRegisterIntoClipboard()
  vim.cmd([[
silent call writefile(getreg('0', 1, 1), "/tmp/clipboard-ssh")
silent !cat /tmp/clipboard-ssh | ~/.scripts/cargo_target/release/clipboard_ssh send && rm /tmp/clipboard-ssh
]])
end

vim.api.nvim_set_keymap("n", "<leader>mf", "", {
  callback = function()
    local file_path = vim.fn.expand("%:p")
    vim.fn.setreg("0", file_path)
    SaveRegisterIntoClipboard()
    print(file_path)
  end,
  desc = "Copy file relative path to clipboard",
  silent = true,
})

vim.api.nvim_set_keymap("n", "<leader>mF", "", {
  callback = function()
    local file_path = vim.fn.expand("%:P")
    vim.fn.setreg("0", file_path)
    SaveRegisterIntoClipboard()
    print(file_path)
  end,
  desc = "Copy file absolute path to clipboard",
  silent = true,
})

local eslint_rules = {
  { "no-console",                         "c" },
  { "playwright/no-conditional-in-test",  "t" },
  { "@typescript-eslint/no-explicit-any", "a" },
  { "@typescript-eslint/no-var-requires", "v" },
}
for _, map in ipairs(eslint_rules) do
  vim.api.nvim_set_keymap("n", "<leader>ml" .. map[2], "O// eslint-disable-next-line " .. map[1] .. "<esc>",
    { noremap = true, silent = true })
end

-- In the host `.ssh/config` file add this to forward the remote port into the local
-- RemoteForward 2030 localhost:2030
local clipboard_maps = {
  { "v", "<leader>i", "y" }, { "n", "<leader>i", "viwy" }, { "n", "<leader>I", "viWy" }
}
for _, map in ipairs(clipboard_maps) do
  vim.api.nvim_set_keymap(map[1], map[2], "",
    {
      noremap = true,
      silent = true,
      desc = "Copy to clipboard or register",
      callback = function()
        vim.cmd("normal! " .. map[3])
        SaveRegisterIntoClipboard()
        vim.cmd("redraw")
      end,
    })
end

require("react_css")
require("yarn_workspace")
