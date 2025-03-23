return {
  {
    "max397574/better-escape.nvim",
    event = "InsertEnter",
    config = function()
      require("better_escape").setup({
        timeout = vim.o.timeoutlen,
        mappings = {
          i = {
            k = {
              -- These can all also be functions
              j = "<Esc>",
            },
          },
          c = {
            k = {
              j = "<Esc>",
            },
          },
          t = {
            k = {
              j = "<Esc>",
            },
          },
          v = {
            k = {
              j = "<Esc>",
            },
          },
          s = {
            k = {
              j = "<Esc>",
            },
          },
        },
      })
    end,
  },
}
