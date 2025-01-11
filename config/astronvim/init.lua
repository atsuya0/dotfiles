-- https://github.com/AstroNvim/user_example

return {
  --colorscheme = "everforest"

  vim.api.nvim_create_augroup("imeoff", { clear = true }),
  vim.api.nvim_create_autocmd("InsertLeave", {
    desc = "Turn off IME when exiting from insert mode",
    pattern = "*",
    group = "imeoff",
    callback = function()
      if vim.fn.has("macunix") == 1 then
        vim.fn.system("/opt/homebrew/bin/im-select com.apple.keylayout.ABC")
      elseif vim.fn.has("unix") == 1 then
        vim.fn.system("fcitx5-remote -c")
      end
    end,
  })
}
