-- This file simply bootstraps the installation of Lazy.nvim and then calls other files for execution
-- This file doesn't necessarily need to be touched, BE CAUTIOUS editing this file and proceed at your own risk.
local lazypath = vim.env.LAZY or vim.fn.stdpath "data" .. "/lazy/lazy.nvim"
if not (vim.env.LAZY or (vim.uv or vim.loop).fs_stat(lazypath)) then
  -- stylua: ignore
  vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath })
end
vim.opt.rtp:prepend(lazypath)

-- validate that lazy is available
if not pcall(require, "lazy") then
  -- stylua: ignore
  vim.api.nvim_echo({ { ("Unable to load lazy from: %s\n"):format(lazypath), "ErrorMsg" }, { "Press any key to exit...", "MoreMsg" } }, true, {})
  vim.fn.getchar()
  vim.cmd.quit()
end

require "lazy_setup"
require "polish"

vim.api.nvim_create_augroup("imeoff", { clear = true })
vim.api.nvim_create_autocmd("InsertLeave", {
  desc = "Turn off IME when exiting from insert mode",
  pattern = "*",
  group = "imeoff",
  callback = function()
    if vim.fn.has("macunix") == 1 then
      vim.fn.system("/opt/homebrew/bin/im-select com.google.inputmethod.Japanese.Roman")
    elseif vim.fn.has("unix") == 1 then
      vim.fn.system("fcitx5-remote -c")
    end
  end,
})

