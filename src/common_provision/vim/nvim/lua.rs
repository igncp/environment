use crate::base::Context;

pub fn setup_nvim_lua(context: &mut Context) {
    std::fs::create_dir_all(context.system.get_home_path(".vim/lua")).unwrap();

    context.files.append(
        &context.system.get_home_path(".vim/lua/extra_beginning.lua"),
        r###"
-- https://github.com/folke/lazy.nvim
-- Press `:Lazy` to open the popup, and `?` to see the help
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- This variable is populated with the packages
local nvim_plugins = {
}

require("lazy").setup(nvim_plugins)

function try_marks()
  require('marks').setup({
    default_mappings = true,
  })
end

pcall(try_marks)

vim.api.nvim_set_keymap("i", "<C-_>", "<Plug>(copilot-next)", {silent = true, nowait = true})
vim.api.nvim_set_keymap("i", "<C-\\>", "<Plug>(copilot-previous)", {silent = true, nowait = true})

-- Undo tree
vim.api.nvim_set_keymap("n", "<leader>mm", ":UndotreeShow<cr><c-w><left>", { noremap = true })

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

-- Vista
vim.g.vista_default_executive = 'coc'
vim.g.vista_sidebar_width = 100

-- limelight
vim.g.limelight_conceal_ctermfg = 'LightGray'
vim.g.limelight_bop = '^'
vim.g.limelight_eop = '$'
vim.api.nvim_set_keymap("n", "<leader>zl", ":Limelight!!<cr>", { noremap = true })
vim.api.nvim_set_keymap("n", "<leader>zL", ":let g:limelight_paragraph_span = <left><right>", { noremap = true })

-- auto-pairs
vim.g.AutoPairsMultilineClose = 0

-- incsearch.vim
vim.api.nvim_set_keymap("n", "/", "<Plug>(incsearch-forward)", {})
vim.api.nvim_set_keymap("n", "?", "<Plug>(incsearch-backward)", {})
vim.api.nvim_set_keymap("n", "g/", "<Plug>(incsearch-stay)", {})

-- nerdcommenter
vim.g.NERDSpaceDelims = 1

-- vim fugitive
vim.cmd('set diffopt+=vertical')
vim.cmd('command Gb Git blame')

-- vim-json
vim.g.vim_json_syntax_conceal = 0

-- save file shortcuts
vim.api.nvim_set_keymap("n", "<leader>ks", ':silent exec "!mkdir -p <c-R>=expand("%:p:h")<cr>"<cr>:w<cr>:silent exec ":CtrlPClearAllCaches"<cr>', { noremap = true })

-- markdown
vim.g.vim_markdown_auto_insert_bullets = 0
vim.g.vim_markdown_new_list_item_indent = 0
vim.g.vim_markdown_conceal = 0
vim.g.tex_conceal = ""
vim.g.vim_markdown_math = 1
vim.g.vim_markdown_folding_disabled = 1
vim.cmd 'autocmd Filetype markdown set conceallevel=0'

-- format json
vim.cmd 'command! -range -nargs=0 -bar JsonTool <line1>,<line2>!python -m json.tool'
vim.api.nvim_set_keymap("n", "<leader>kz", ':JsonTool<cr>', { noremap = true })
vim.api.nvim_set_keymap("v", "<leader>kz", ":'<,'>JsonTool<cr>", { noremap = true })

vim.g.peekaboo_window='vert bo new'

function select_indent(around)
    local start_indent = vim.fn.indent(vim.fn.line('.'))
    local prev_line = vim.fn.line('.') - 1
    local blank_line_pattern = '^%s*$'

    while prev_line > 0 and vim.fn.indent(prev_line) >= start_indent do
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

for _,mode in ipairs({ 'x', 'o' }) do
    vim.api.nvim_set_keymap(mode, 'ii', ':<c-u>lua select_indent()<cr>', { noremap = true, silent = true })
    vim.api.nvim_set_keymap(mode, 'ai', ':<c-u>lua select_indent(true)<cr>', { noremap = true, silent = true })
end

local function file_exists(name)
   local f=io.open(name,"r")
   if f~=nil then io.close(f) return true else return false end
end

local theme_path = os.getenv("HOME") .. '/development/environment/project/.config/vim-theme'

if file_exists(theme_path) then
  local file = io.open(theme_path, "rb")
  if not file then return nil end
  local content = file:read "*a"
  file:close()
  vim.cmd("colorscheme " .. content)
end
"###,
    );
}
