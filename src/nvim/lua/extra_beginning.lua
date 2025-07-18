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

local versions_path = os.getenv("HOME") .. '/development/environment/src/versions.json'
local versions_file = io.open(versions_path, "rb")

if not versions_file then
  print("No environment/src/versions.json file found")
  return nil
end

local versions_content = versions_file:read "*a"
versions_file:close()

local function get_version(name)
  local pattern = '"%s*' .. name .. '%s*":%s*"([^"]+)"'
  pattern = pattern:gsub("-", ".")
  local version = versions_content:match(pattern)
  if version then
    return version
  else
    print(name)
    return nil
  end
end

-- 此變數由包填充
local nvim_plugins = {
  {
    "yaegassy/coc-phpstan",
    enabled = function()
      return vim.fn.executable('php') == 1
    end,
  },
  {
    "josa42/coc-go",
    enabled = function()
      return vim.fn.executable('go') == 1
    end,
  },
  -- https://github.com/mrcjkb/haskell-tools.nvim
  {
    'mrcjkb/haskell-tools.nvim',
    version = '^3',
    lazy = false,
    enabled = function()
      return vim.fn.executable('runhaskell') == 1
    end,
  },
  {
    "rcarriga/nvim-dap-ui",
    dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" }
  },
  {
    "leoluz/nvim-dap-go",
    enabled = function()
      return vim.fn.executable('go') == 1
    end,
  },
  -- "vim-ruby/vim-ruby",
  "udalov/kotlin-vim",
  "smoka7/hop.nvim",
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    commit = get_version("neovim.CopilotChat.nvim"),
    dependencies = {
      { "nvim-lua/plenary.nvim" },
    },
    opts = {
      debug = true,
    },
  },
  -- https://github.com/chrisgrieser/nvim-various-textobjs
  {
    "chrisgrieser/nvim-various-textobjs",
    lazy = false,
    opts = { keymaps = { useDefaults = true } },
  },
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate"
  },
  -- https://github.com/nvim-treesitter/nvim-treesitter-textobjects
  "nvim-treesitter/nvim-treesitter-textobjects",
  "jbyuki/venn.nvim",
  "neovim/nvim-lspconfig",
  "nvimdev/lspsaga.nvim",
  {
    'nvim-telescope/telescope.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' }
  },
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    commit = get_version("neovim.indent-blankline.nvim"),
    opts = {
      scope = {
        show_start = false,
        show_end = false,
      }
    }
  },
  {
    'Wansmer/treesj',
    dependencies = { 'nvim-treesitter/nvim-treesitter' }, -- if you install parsers with `nvim-treesitter`
    config = function()
      require('treesj').setup({
        use_default_keymaps = false,
      })
    end,
  },
  {
    'nvim-flutter/flutter-tools.nvim',
    lazy = false,
    commit = get_version('neovim.flutter-tools.nvim'),
    dependencies = {
      'nvim-lua/plenary.nvim',
      'stevearc/dressing.nvim', -- 可選，對於 vim.ui.select
    },
    enabled = function()
      return vim.fn.executable('dart') == 1
    end,
    config = true,
  },
  { "junegunn/limelight.vim",         commit = get_version("neovim.limelight.vim") },
  { "LnL7/vim-nix",                   commit = get_version("neovim.vim-nix") },
  { "jiangmiao/auto-pairs",           commit = get_version("neovim.auto-pairs") },
  { "neoclide/coc.nvim",              commit = get_version("neovim.coc.nvim") },
  { "ctrlpvim/ctrlp.vim",             commit = get_version("neovim.ctrlp.vim") },
  { "sindrets/diffview.nvim",         commit = get_version("neovim.diffview.nvim") },
  { "tommcdo/vim-exchange",           commit = get_version("neovim.vim-exchange") },
  { "tpope/vim-eunuch",               commit = get_version("neovim.vim-eunuch") },
  { "tpope/vim-fugitive",             commit = get_version("neovim.vim-fugitive") },
  { "tpope/vim-repeat",               commit = get_version("neovim.vim-repeat") },
  { "tpope/vim-surround",             commit = get_version("neovim.vim-surround") },
  { "lewis6991/gitsigns.nvim",        commit = get_version("neovim.gitsigns.nvim") },
  { "liuchengxu/vista.vim",           commit = get_version("neovim.vista.vim") },
  { "mbbill/undotree",                commit = get_version("neovim.undotree") },
  { "mfussenegger/nvim-dap",          commit = get_version("neovim.nvim-dap") },
  { "ntpeters/vim-better-whitespace", commit = get_version("neovim.vim-better-whitespace") },
  { "plasticboy/vim-markdown",        commit = get_version("neovim.vim-markdown") },
  { "rhysd/clever-f.vim",             commit = get_version("neovim.clever-f.vim") },
  { "ryanoasis/vim-devicons",         commit = get_version("neovim.vim-devicons") }, -- 如果不支持，請在custom.sh中添加: rm -rf ~/.local/share/nvim/lazy/vim-devicons/*
  { "scrooloose/nerdcommenter",       commit = get_version("neovim.nerdcommenter") },
  { "vim-scripts/AnsiEsc.vim",        commit = get_version("neovim.AnsiEsc.vim") },
  { "NvChad/nvim-colorizer.lua",      commit = get_version("neovim.nvim-colorizer.lua") },
  { "bogado/file-line",               commit = get_version("neovim.file-line") },
  { "chentoast/marks.nvim",           commit = get_version("neovim.marks.nvim") },
  { "elzr/vim-json",                  commit = get_version("neovim.vim-json") },
  { "google/vim-searchindex",         commit = get_version("neovim.vim-searchindex") },
  { "haya14busa/incsearch.vim",       commit = get_version("neovim.incsearch.vim") },
  { "honza/vim-snippets",             commit = get_version("neovim.vim-snippets") },
  { "iamcco/markdown-preview.nvim",   commit = get_version("neovim.markdown-preview.nvim") },
  { "jparise/vim-graphql",            commit = get_version("neovim.vim-graphql") },
  { "junegunn/vim-peekaboo",          commit = get_version("neovim.vim-peekaboo") },
  { "lbrayner/vim-rzip",              commit = get_version("neovim.vim-rzip") },
  { "cocopon/iceberg.vim",            commit = get_version("neovim.iceberg.vim") },
  { "morhetz/gruvbox",                commit = get_version("neovim.gruvbox") },
  { "dracula/vim",                    commit = get_version("neovim.vim") },
}

require("lazy").setup(nvim_plugins)

vim.keymap.set('n', 'gM', require('treesj').toggle)
vim.keymap.set('n', 'gS', require('treesj').split)
vim.keymap.set('n', 'gJ', require('treesj').join)

require('gitsigns').setup()

require('hop').setup({
  -- Hop configuration goes there
})

vim.api.nvim_set_keymap("n", "E", ":HopChar2<cr>",
  { silent = true, nowait = true })

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

vim.cmd([[
hi TabLine guibg=LightBlue
hi TabLine guifg=Black
hi TabLineSel guibg=Orange
hi TabLineSel guifg=Black

hi Comment guifg=lightcyan

hi @keyword.import.tsx guifg=#e3d688
hi @keyword.import.typescript guifg=#e3d688
]])

local custom_path = os.getenv("HOME") ..
    '/development/environment/project/.vim-custom.lua'

if M.file_exists(custom_path) then
  dofile(custom_path)
end

vim.api.nvim_set_keymap("n", "<c-f>", ":call SpecialMaps()<cr>",
  { noremap = true })
vim.api.nvim_set_keymap("i", "<c-f>", "<c-c>:call SpecialMaps()<cr>",
  { noremap = true })

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
  local has_config_file = M.has_config("no-clipboard-ssh")

  if has_config_file then
    vim.cmd([[
silent call setreg('+', getreg('0', 1, 1))
]])

    return
  end

  vim.cmd([[
silent call writefile(getreg('0', 1, 1), "/tmp/clipboard-ssh")
silent !cat /tmp/clipboard-ssh | $HOME/.local/bin/clipboard_ssh send && rm /tmp/clipboard-ssh
]])
end

vim.api.nvim_set_keymap("n", "<leader>mf", "", {
  callback = function()
    local file_path = vim.fn.expand("%:p")
    vim.fn.setreg("0", file_path)
    SaveRegisterIntoClipboard()
    print(file_path)
  end,
  desc = "將檔案絕對路徑複製到剪貼簿",
  silent = true,
})

vim.api.nvim_set_keymap("n", "<leader>mF", "", {
  callback = function()
    local file_path = vim.fn.expand("%:P")
    vim.fn.setreg("0", file_path)
    SaveRegisterIntoClipboard()
    print(file_path)
  end,
  desc = "將檔案相對路徑複製到剪貼簿",
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
  { "v", "<leader>i", "y", false }, { "v", "<leader>I", "y", true }
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
        if map[4] then
          vim.cmd("q!")
        end
      end,
    })
end

require("react_css")
require("yarn_workspace")

require("colorizer").setup {
  filetypes = { "*" },
  user_default_options = {
    RGB = true,                                     -- #RGB hex codes
    RRGGBB = true,                                  -- #RRGGBB hex codes
    names = true,                                   -- "Name" codes like Blue or blue
    RRGGBBAA = true,                                -- #RRGGBBAA hex codes
    AARRGGBB = true,                                -- 0xAARRGGBB hex codes
    rgb_fn = true,                                  -- CSS rgb() and rgba() functions
    hsl_fn = true,                                  -- CSS hsl() and hsla() functions
    css = true,                                     -- Enable all CSS features: rgb_fn, hsl_fn, names, RGB, RRGGBB
    css_fn = true,                                  -- Enable all CSS *functions*: rgb_fn, hsl_fn
    mode = "virtualtext",                           -- Set the display mode.
    tailwind = true,                                -- Enable tailwind colors
    sass = { enable = true, parsers = { "css" }, }, -- Enable sass colors
    virtualtext = "◀",
    always_update = true
  },
  -- all the sub-options of filetypes apply to buftypes
  buftypes = {},
}

vim.cmd([[
function! ClearWhitespaceInFile()
  let l:save = winsaveview()
  keeppatterns %s/\s\+$//e
  call winrestview(l:save)
endfunction
]])

-- https://github.com/jbyuki/venn.nvim
function _G.Toggle_venn()
  local venn_enabled = vim.inspect(vim.b.venn_enabled)
  if venn_enabled == "nil" then
    ---@diagnostic disable-next-line inject-field
    vim.b.venn_enabled = true
    vim.cmd [[setlocal ve=all]]
    vim.api.nvim_buf_set_keymap(0, "n", "J", "<C-v>j:VBox<CR>", { noremap = true })
    vim.api.nvim_buf_set_keymap(0, "n", "K", "<C-v>k:VBox<CR>", { noremap = true })
    vim.api.nvim_buf_set_keymap(0, "n", "L", "<C-v>l:VBox<CR>", { noremap = true })
    vim.api.nvim_buf_set_keymap(0, "n", "H", "<C-v>h:VBox<CR>", { noremap = true })
    vim.api.nvim_buf_set_keymap(0, "v", "f", ":VBox<CR>", { noremap = true })
  else
    vim.cmd [[setlocal ve=]]
    vim.api.nvim_buf_del_keymap(0, "n", "J")
    vim.api.nvim_buf_del_keymap(0, "n", "K")
    vim.api.nvim_buf_del_keymap(0, "n", "L")
    vim.api.nvim_buf_del_keymap(0, "n", "H")
    vim.api.nvim_buf_del_keymap(0, "v", "f")
    ---@diagnostic disable-next-line inject-field
    vim.b.venn_enabled = nil
  end
end

-- 使用 <leader>v 切換 venn 的鍵盤映射
vim.api.nvim_set_keymap('n', '<leader>v', ":lua Toggle_venn()<CR>", { noremap = true })

vim.api.nvim_set_keymap("n", "<F10>", "", {
  callback = function()
    local output = ""

    -- hi
    local synid = vim.fn.synID(vim.fn.line("."), vim.fn.col("."), 1)
    output = output .. "hi<" .. vim.fn.synIDattr(synid, "name") .. ">"

    -- trans
    synid = vim.fn.synID(vim.fn.line("."), vim.fn.col("."), 0)
    output = output .. " trans<" .. vim.fn.synIDattr(synid, "name") .. ">"

    -- lo
    synid = vim.fn.synIDtrans(vim.fn.synID(vim.fn.line("."), vim.fn.col("."), 1))
    output = output .. " lo<" .. vim.fn.synIDattr(synid, "name") .. ">"

    print(output)
  end,
  desc = "了解遊標下的語法類型",
  silent = true,
})

if M.has_config("nvim-lspconfig") then
  require('telescope').setup {
    defaults = {
      previewer = true,
      file_previewer = require 'telescope.previewers'.vim_buffer_cat.new,
      grep_previewer = require 'telescope.previewers'.vim_buffer_vimgrep.new,
      qflist_previewer = require 'telescope.previewers'.vim_buffer_qflist.new,
    }
  }

  -- https://nvimdev.github.io/lspsaga/
  require('lspsaga').setup {
    codeaction = {
      show_server_name = true,
    },
    lightbulb = {
      enable = false,
    },
  }

  local servers = { { 'rust_analyzer' }, { 'tsserver' }, { 'ruby_lsp' },
    { 'bashls' },
  }

  for _, lsp in pairs(servers) do
    local lsp_name = lsp[1]
    local lsp_config = lsp[2] or {}
    require('lspconfig')[lsp_name].setup(lsp_config)
  end

  vim.diagnostic.config { virtual_text = false }

  vim.api.nvim_set_keymap("n", "gd", ":lua vim.lsp.buf.definition()<cr>",
    { noremap = true, silent = true })

  vim.api.nvim_set_keymap("n", "gr", ":lua require'telescope.builtin'.lsp_references" ..
    "{include_declaration = true}<cr>",
    { noremap = true, silent = true })

  vim.api.nvim_set_keymap("n", "gy", ":lua require'telescope.builtin'.lsp_type_definitions{}<cr>",
    { noremap = true, silent = true })

  vim.api.nvim_set_keymap("n", "gY", ":lua require'telescope.builtin'.lsp_implementations{}<cr>",
    { noremap = true, silent = true })

  vim.api.nvim_set_keymap("n", "g]", "", {
    callback = function() vim.diagnostic.goto_next() end,
  })

  vim.api.nvim_set_keymap("n", "g[", "", {
    callback = function() vim.diagnostic.goto_prev() end,
  })

  vim.api.nvim_set_keymap("n", "<leader>da", ":Lspsaga code_action<CR>",
    { silent = true, nowait = true })

  vim.api.nvim_create_autocmd("BufWritePre", {
    callback = function()
      vim.lsp.buf.format { async = false }
    end
  })
else
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

  -- 片段顯示
  vim.api.nvim_set_keymap("n", "<leader>ms",
    ":CocCommand snippets.openSnippetFiles<cr>",
    { noremap = true })

  -- Vista
  vim.g.vista_default_executive = 'coc'
  vim.g.vista_sidebar_width = 100
end

require 'nvim-treesitter.configs'.setup {
  auto_install = true,
  highlight = {
    disable = {
      -- 連結顏色不正確
      "markdown"
    },
    enable = true,
  },
}

local hooks = require "ibl.hooks"

hooks.register(hooks.type.ACTIVE, function()
  return vim.bo.filetype == "yaml"
end)

vim.api.nvim_create_autocmd({ 'BufRead', 'BufNewFile' }, {
  pattern = 'Fastfile',
  command = 'setf ruby'
})

vim.api.nvim_create_autocmd({ 'BufRead', 'BufNewFile' }, {
  pattern = 'Podfile',
  command = 'setf ruby'
})
