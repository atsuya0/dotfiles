vim.g.base46_cache = vim.fn.stdpath "data" .. "/base46/"
vim.g.mapleader = " "

-- bootstrap lazy and all plugins
local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"

if not vim.uv.fs_stat(lazypath) then
  local repo = "https://github.com/folke/lazy.nvim.git"
  vim.fn.system { "git", "clone", "--filter=blob:none", repo, "--branch=stable", lazypath }
end

vim.opt.rtp:prepend(lazypath)

local lazy_config = require "configs.lazy"

-- load plugins
require("lazy").setup({
  {
    "NvChad/NvChad",
    lazy = false,
    branch = "v2.5",
    import = "nvchad.plugins",
  },

  { import = "plugins" },
}, lazy_config)

-- load theme
dofile(vim.g.base46_cache .. "defaults")
dofile(vim.g.base46_cache .. "statusline")

require "options"
require "nvchad.autocmds"

vim.schedule(function()
  require "mappings"
end)

--

local ime_off = vim.api.nvim_create_augroup("ime_off", { clear = true })
vim.api.nvim_create_autocmd("InsertLeave", {
  pattern = "*",
  group = ime_off,
  callback = function()
    if vim.fn.has "macunix" == 1 then
      vim.fn.system "/opt/homebrew/bin/im-select com.google.inputmethod.Japanese.Roman"
    elseif vim.fn.has "unix" == 1 then
      vim.fn.system "fcitx5-remote -c"
    end
  end,
})
