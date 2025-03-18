return {
  {
    "stevearc/conform.nvim",
    event = "BufWritePre", -- uncomment for format on save
    opts = {
      formatters_by_ft = {
        lua = { "stylua" },
        python = { "black", "isort" },
        go = { "gofmt", "goimports" },
        sql = { "sqlfmt" },
        terraform = { "terraform_fmt" },
        ansible = { "ansible-lint" },
        bash = { "shfmt" },
      },
      format_on_save = true,
      format_options = {
        timeout_ms = 1000,
      },
    },
  },

  -- These are some examples, uncomment them if you want to see them work!
  {
    "neovim/nvim-lspconfig",
    config = function()
      require "configs.lspconfig"
    end,
  },

  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "vim",
        "lua",
        "vimdoc",
        "html",
        "css",
        "markdown",
        "bash",
        "go",
        "python",
        "terraform",
        "hcl",
      },
    },
  },
}
