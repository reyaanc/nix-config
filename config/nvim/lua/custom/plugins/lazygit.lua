-- [[ lazygit ]]
--  Opens lazygit in a new tab and closes the tab when lazygit exits.
--
--  - `<leader>gg` open lazygit
vim.keymap.set('n', '<leader>gg', function()
  vim.cmd.tabnew()
  local buf = vim.api.nvim_get_current_buf()
  vim.fn.jobstart('lazygit', {
    term = true,
    on_exit = function() vim.api.nvim_buf_delete(buf, { force = true }) end,
  })
  vim.cmd.startinsert()
end, { desc = 'Lazy[G]it' })
