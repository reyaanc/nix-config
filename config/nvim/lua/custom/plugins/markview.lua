-- [[ markview.nvim ]]
--  Renders markdown in the buffer: headings, code blocks, tables, lists,
--  checkboxes and callouts. The line under the cursor shows raw text for editing.
vim.pack.add { 'https://github.com/OXY2DEV/markview.nvim' }

vim.keymap.set('n', '<leader>tm', '<cmd>Markview toggle<cr>', { desc = '[T]oggle [M]arkdown rendering' })
