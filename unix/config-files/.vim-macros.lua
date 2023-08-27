-- You can open this file with <leader>ee
-- You can also open ~/development/environment/project/.vim-custom.lua with <leader>eE
-- To refresh the custom file use: <leader>er

-- Convert jsx prop to object property
vim.cmd([===[let @X = "_f=i\<del>: \<c-c>\<right>%s,\<c-c>``s\<c-c>``j"]===])

-- Create test property
vim.cmd([===[let @X = "_f:v$\<left>\<del>A: \<c-c>_viwyA''\<c-c>\<left>paValue\<c-c>A,\<c-c>_\<down>"]===])

-- Wrap type object in tag
vim.cmd([===[let @X = "i<\<c-c>\<right>%a>\<c-c>\<left>%\<left>"]===])
