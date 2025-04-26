local current_user = os.getenv("USER") or os.getenv("USERNAME") or "Me"

return {
  {
    "olimorris/codecompanion.nvim",
    opts = {
      strategies = {
        chat = {
          roles = {
            ---The header name for the LLM's messages
            ---@type string|fun(adapter: CodeCompanion.Adapter): string
            llm = function(adapter)
              return "CodeCompanion [" .. adapter.formatted_name .. "]"
            end,

            ---The header name for your messages
            ---@type string
            user = current_user,
          },
        },
      },
      display = {
        chat = {
          window = {
            width = 0.48,
          },
        },
      },
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
  },
}
