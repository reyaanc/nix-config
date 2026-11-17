-- [[ Undotree ]]
--  Built into Neovim 0.12; browse the undo history as a tree.
--
--  - `<leader>u` toggle the undo tree
vim.cmd.packadd 'nvim.undotree'

vim.keymap.set('n', '<leader>u', '<cmd>Undotree<cr>', { desc = '[U]ndo tree' })
