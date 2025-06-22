return {
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    dependencies = {
      { "github/copilot.vim" },
      { "nvim-lua/plenary.nvim", branch = "master" }, -- for curl, log and async functions
    },
    build = "make tiktoken", -- Only on MacOS or Linux
    opts = {
      -- See Configuration section for options
      question_header = "  " .. vim.env.USER .. " ",
      answer_header = "  Copilot ",
      separator = "✦ ✦ ✦ ✦ ✦ ✦ ✦ ✦ ✦ ✦ ✦ ✦ ✦ ✦ ✦ ✦ ✦ ✦ ✦ ✦ ✦ ✦ ✦ ✦ ✦ ✦ ✦ ✦ ✦ ✦ ✦ ✦ ✦ ✦ ✦ ✦ ✦ ✦ ✦ ✦",

      Rename = {
        prompt = "Please rename the variable correctly in given selection based on context",
        selection = function(source)
          local select = require("CopilotChat.select")
          return select.visual(source)
        end,
      },

      mappings = {
        -- Use <C-r> to reset the chat window
        reset = {
          normal = "<C-r>",
          insert = "<C-r>",
        },
      },
    },
    keys = {
      { "<space>z", ":CopilotChatToggle<CR>", mode = { "n", "v" }, desc = "Chat with Copilot" },
      { "<leader>zt", ":CopilotChatStop<CR>", mode = { "n", "v" }, desc = "Stop Current Output" },
      { "<leader>zc", ":CopilotChatReset<CR>", mode = { "n", "v" }, desc = "Reset Chat Window" },
      { "<leader>zm", ":CopilotChatModels<CR>", mode = { "n", "v" }, desc = "View/Select models" },
      { "<leader>za", ":CopilotChatAgents<CR>", mode = { "n", "v" }, desc = "View/Select agents" },
      { "<leader>zp", ":CopilotChatPrompts<CR>", mode = { "n", "v" }, desc = "View/Select prompt templates" },

      { "<leader>zn", ":CopilotChatRename<CR>", mode = "v", desc = "Rename the variable" },
      { "<leader>ze", ":CopilotChatExplain<CR>", mode = "v", desc = "Explain Code" },
      { "<Leader>zr", ":CopilotChatReview<CR>", mode = "v", desc = "Review Code" },
      { "<leader>zf", ":CopilotChatFix<CR>", mode = "v", desc = "Fix Code Issues" },
      { "<leader>zo", ":CopilotChatOptimize<CR>", mode = "v", desc = "Optimize Code" },
      { "<leader>zd", ":CopilotChatDocs<CR>", mode = "v", desc = "Generate Docs" },
    },
  },
}
