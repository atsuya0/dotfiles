return {
  --colorscheme = "everforest"

  vim.api.nvim_create_augroup("imeoff", { clear = true }),
  vim.api.nvim_create_autocmd("InsertLeave", {
    desc = "Turn off IME when exiting from insert mode",
    pattern = "*",
    group = "imeoff",
    callback = function()
      if vim.fn.has("unix") == 1 then
        vim.fn.system('fcitx5-remote -c')
      elseif vim.fn.has("macunix") == 1 then
      end
    end,
  })
}
