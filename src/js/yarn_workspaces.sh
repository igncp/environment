#!/usr/bin/env bash

set -euo pipefail

provision_setup_js_yarn_workspaces() {
  cat >>~/.zshrc <<"EOF"
zle -N custom_yarn_workspace
custom_yarn_workspace () {
  if [ ! -f .env ]; then return ; fi
  PROJECT_NAME=$(cat .env | grep PROJECT_NAME | cut -d '=' -f2)
  if [ -z "$PROJECT_NAME" ]; then return ; fi
  FILE=$(fd . apps/$PROJECT_NAME --type f | fzf)
  if [ -z "$FILE" ]; then return ; fi
  LBUFFER="n $FILE"
  zle accept-line # enter
}
bindkey "\C-q\C-i" custom_yarn_workspace

zle -N custom_yarn_workspace_ui
custom_yarn_workspace_ui () {
  FILE=$(fd . packages/ui --type f | fzf)
  if [ -z "$FILE" ]; then return ; fi
  LBUFFER="n $FILE"
  zle accept-line # enter
}
bindkey "\C-q\C-o" custom_yarn_workspace_ui
EOF

  echo 'require("yarn_workspace")' >>~/.vim/lua/entry.lua

  cat >~/.vim/lua/yarn_workspace.lua <<"EOF"
vim.cmd([[
function! s:yarn_workspaces_sink_base(line)
  redraw
  let g:yarn_workspace = substitute(a:line, '"', '', 'g') .. "/"
endfunction
function! s:yarn_workspaces_sink(line)
  call s:yarn_workspaces_sink_base(a:line)
  execute "lua OpenCorrespondingNodeWorkspaceUI(true, false)"
endfunction
function! s:yarn_workspaces_sink_choose(line)
  call s:yarn_workspaces_sink_base(a:line)
  execute "lua OpenCorrespondingNodeWorkspaceUI(true, true)"
endfunction
function! SelectYarnWorkspace(choose)
  let file_content = system('cat /tmp/yarn-workspaces-list')
  let source_list = split(file_content, '\n')
  let options_dict = {
    \ 'options': ' --ansi --no-hscroll --nth 1,..',
    \ 'source': source_list,
    \ 'sink': a:choose == 0 ? function('s:yarn_workspaces_sink') : function('s:yarn_workspaces_sink_choose'),
    \ }

  call fzf#run(options_dict)
endfunction
]])

function OpenCorrespondingNodeWorkspaceUI(search, choose)
  local full_path = vim.fn.expand('%:P')
  local dir_to_open = ""
  local word_to_search = ""

  if string.match(full_path, 'packages/ui.*') or choose then
    if vim.g.yarn_workspace == nil then
      vim.fn.system(
        'yarn workspaces list --json | jq ".location" | ag -v "\\." > /tmp/yarn-workspaces-list')
      vim.cmd("call SelectYarnWorkspace(" .. (choose and 1 or 0) .. ")")
      return
    end
    dir_to_open = vim.g.yarn_workspace ..
        string.gsub(full_path, '[^/]*%/', '', 2)
    word_to_search = vim.fn.expand('<cword>')
  else
    vim.g.yarn_workspace = string.match(full_path, '([^/]*/[^/]*/)')
    if vim.g.yarn_workspace == nil then
      print('Not in a workspace')
      return
    end
    dir_to_open = "packages/ui/" .. string.gsub(full_path, '[^/]*%/', '', 2)
    word_to_search = vim.fn.expand('<cword>')
  end

  if dir_to_open ~= "" then
    print(dir_to_open)
    vim.cmd('tab drop ' .. dir_to_open)

    if search then
      local function search_item()
        vim.cmd('normal! /\\<' .. word_to_search .. '\\>\r')
      end
      pcall(search_item)
    end
  end
end

vim.api.nvim_set_keymap("n", "<leader>md",
  "",
  {
    noremap = true,
    desc = "Open corresponding node workspace (automatic)",
    callback = function()
      OpenCorrespondingNodeWorkspaceUI(true, false)
    end
  })

vim.api.nvim_set_keymap("n", "<leader>mD",
  "",
  {
    noremap = true,
    desc = "Open corresponding node workspace (chossing with fzf)",
    callback = function()
      vim.g.yarn_workspace = nil
      OpenCorrespondingNodeWorkspaceUI(true, true)
    end
  })
EOF
}
