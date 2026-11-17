-- [[ Extra mini.nvim modules ]]
--  `mini.nvim` is already installed by `init.lua`, so enabling more of its
--  modules costs nothing extra to download.

-- Move lines (normal mode) or selections (visual mode) with Shift + arrow keys.
--  Alt + h/j/k/l would be the default, but AeroSpace takes those system-wide.
--  Reindents automatically when moving in or out of a block.
require('mini.move').setup {
  mappings = {
    left = '<S-Left>',
    right = '<S-Right>',
    down = '<S-Down>',
    up = '<S-Up>',
    line_left = '<S-Left>',
    line_right = '<S-Right>',
    line_down = '<S-Down>',
    line_up = '<S-Up>',
  },
}

-- Auto-close brackets and quotes as you type.
require('mini.pairs').setup()

-- Split or join the contents of brackets with `gS`.
--  e.g. `foo(a, b, c)` <-> one argument per line.
require('mini.splitjoin').setup()

-- Delete a buffer without closing its window or quitting Neovim.
--  The window falls back to another buffer, or an empty one if none are left.
require('mini.bufremove').setup()
vim.keymap.set('n', '<leader>bd', function() MiniBufremove.delete() end, { desc = '[B]uffer [D]elete' })

-- `:q` in the last file window deletes the buffer instead,
--  so you land on the empty one. `:q` from there quits as usual.
vim.keymap.set('ca', 'q', function()
  if vim.fn.getcmdtype() ~= ':' or vim.fn.getcmdline() ~= 'q' or vim.v.char ~= '\r' then return 'q' end
  if vim.bo.buftype ~= '' or vim.api.nvim_buf_get_name(0) == '' then return 'q' end
  local editor_windows = vim.tbl_filter(
    function(win) return vim.api.nvim_win_get_config(win).relative == '' end,
    vim.api.nvim_tabpage_list_wins(0)
  )
  return #editor_windows == 1 and 'lua MiniBufremove.delete()' or 'q'
end, { expr = true })
