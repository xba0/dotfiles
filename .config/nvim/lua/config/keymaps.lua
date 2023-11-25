-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
--

local function map(mode, lhs, rhs, opts)
  local keys = require("lazy.core.handler").handlers.keys
  ---@cast keys LazyKeysHandler
  -- do not create the keymap if a lazy keys handler exists
  if not keys.active[keys.parse({ lhs, mode = mode }).id] then
    opts = opts or {}
    opts.silent = opts.silent ~= false
    vim.keymap.set(mode, lhs, rhs, opts)
  end
end

local lazyterm = function(cwd)
  require("lazyvim.util").terminal.open(nil, { cwd = cwd, border = "rounded" })
end

map("n", "<s-q>", "<cmd>w<cr>", { desc = "Save file" })

map({ "n", "v" }, "<s-h>", "^", { desc = "Soft line front" })
map({ "n", "v" }, "<s-l>", "g_", { desc = "Soft line end" })

map("n", "<a-h>", "<cmd>bprevious<cr>", { desc = "Prev buffer" })
map("n", "<a-l>", "<cmd>bnext<cr>", { desc = "Next buffer" })

map("i", "<c-h>", "<left>")
map("i", "<c-l>", "<right>")

map("n", "<leader>ft", lazyterm, { desc = "Terminal (root dir)" })
map("n", "<leader>fT", function()
  lazyterm(require("lazyvim.util").root.get())
end, { desc = "Terminal (cwd)" })
map("n", "<c-_>", lazyterm, { desc = "Terminal (root dir)" })

map("n", "<leader>r", "<cmd>w<cr><leader>ft<up><cr>", { desc = "quick run", remap = true })