return {

  -- catppuccin
  {
    "catppuccin/nvim",
    lazy = true,
    name = "catppuccin",
    opts = {
      flavour = "mocha",
      integrations = {
        cmp = true,
        flash = true,
        fzf = true,
        grug_far = true,
        gitsigns = true,
        headlines = true,
        illuminate = true,
        indent_blankline = { enabled = true },
        leap = true,
        lsp_trouble = true,
        mason = true,
        markdown = true,
        mini = true,
        native_lsp = {
          enabled = true,
          underlines = {
            errors = { "undercurl" },
            hints = { "undercurl" },
            warnings = { "undercurl" },
            information = { "undercurl" },
          },
        },
        navic = { enabled = true, custom_bg = "lualine" },
        neotest = true,
        neotree = true,
        noice = true,
        notify = true,
        semantic_tokens = true,
        snacks = true,
        telescope = true,
        treesitter = true,
        treesitter_context = true,
        which_key = true,
      },
      custom_highlights = function(colors)
        return {
          FloatBorder = { fg = colors.mauve },
          NormalFloat = { bg = colors.base },
          -- snacks
          -- picker
          SnacksPickerPrompt = { fg = colors.red },
          SnacksPickerTerminalTitle = { fg = colors.base, bg = colors.teal },
          SnacksPickerLazygitTitle = { fg = colors.base, bg = colors.red },
          SnacksPickerTitle = { fg = colors.base, bg = colors.red },
          SnacksPickerListCursorLine = { bg = colors.surface0 },
          SnacksPickerPreview = { bg = colors.mantle },
          SnacksPickerPreviewTitle = { fg = colors.base, bg = colors.green },
          SnacksPickerPreviewBorder = { fg = colors.mantle, bg = colors.mantle },
          SnacksPickerInput = { fg = colors.text, bg = colors.surface0 },
          SnacksPickerInputBorder = { fg = colors.surface0, bg = colors.surface0 },
          SnacksPickerList = { bg = colors.base },
          SnacksPickerListBorder = { fg = colors.base, bg = colors.base },
          SnacksPickerBoxBorder = { fg = colors.mauve, bg = colors.base },
          -- CursorMoved url
          HighlightCursorUrl = { bg = colors.none, fg = colors.red },
          -- TreesitterContext
          TreesitterContextLineNumber = { fg = colors.overlay0, bg = colors.base },
          TreesitterContextBottom = { bg = colors.surface0 },
          -- statusline
          StatusLine = { fg = colors.mauve },
          -- noice
          NoiceCmdlineIcon = { fg = colors.blue },
          NoiceCmdlinePopupBorder = { fg = colors.mauve },
          -- blink
          BlinkCmpMenu = { bg = colors.base },
          BlinkCmpMenuBorder = { fg = colors.mauve },
          BlinkCmpDoc = { bg = colors.base },
          BlinkCmpDocBorder = { fg = colors.mauve },
          BlinkCmpDocSeparator = { fg = colors.mauve, bg = colors.base },
          BlinkCmpScrollBarThumb = { bg = colors.mauve },
          BlinkCmpMenuSelection = { bg = colors.surface0 },
          -- which_key
          WhichKey = { fg = colors.subtext0, bg = colors.base },
          WhichKeyNormal = { fg = colors.mauve, bg = colors.base },
          WhichKeyTitle = { fg = colors.mauve },
          -- avante
          AvanteInlineHint = { fg = colors.teal },
          AvanteSidebar = { bg = colors.mantle },
          AvanteSidebarNormal = { bg = colors.mantle },
          AvanteSidebarWinSeparator = { fg = colors.mantle, bg = colors.mantle },
          AvanteSidebarWinHorizontalSeparator = { fg = colors.crust, bg = colors.mantle },
          AvantePopupHint = { fg = colors.mauve, bg = colors.mantle },
          AvanteTitle = { bg = colors.green, fg = colors.base },
          AvanteSubtitle = { bg = colors.teal, fg = colors.base },
          AvanteThirdTitle = { bg = colors.surface0, fg = colors.subtext0 },
          -- edgy
          EdgyNormal = { bg = colors.mantle, fg = colors.subtext0 },
          EdgyTitle = { bold = true, cterm = { bold = true }, fg = colors.base, bg = colors.mauve },

          -- codecompanion
          CodeCompanionChatHeader = { fg = colors.yellow },
          CodeCompanionChatTokens = { fg = colors.rosewater },
          CodeCompanionChatTool = { fg = colors.teal },
          CodeCompanionChatToolGroups = { fg = colors.lavender },
          CodeCompanionChatVariable = { fg = colors.sky },
          CodeCompanionVirtualText = { fg = colors.overlay0 },
        }
      end,
    },
    specs = {
      {
        "akinsho/bufferline.nvim",
        optional = true,
        opts = function(_, opts)
          if (vim.g.colors_name or ""):find("catppuccin") then
            opts.highlights = require("catppuccin.groups.integrations.bufferline").get()
          end
        end,
      },
    },
  },
}
