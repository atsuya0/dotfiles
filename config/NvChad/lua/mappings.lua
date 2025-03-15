require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")

-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")

map("n", "j", "gj")
map("n", "k", "gk")
-- Emacs key bindings.
map("i", "<C-f>", "<C-o>l")
map("i", "<C-b>", "<C-o>h")
map("i", "<C-a>", "<C-o>^")
map("i", "<C-e>", "<C-o>$")
map("i", "<C-d>", "<del>")
map("i", "<C-k>", "<C-o>d$")
map("i", "<M-f>", "<C-o>W")
map("i", "<M-b>", "<C-o>B")
map("i", "<M-d>", "<C-o>dW")
map("c", "<C-f>", "<left>")
map("c", "<C-b>", "<right>")
map("c", "<C-a>", "<home>")
map("c", "<C-d>", "<del>")
