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
      custom_highlights = {
        FloatBorder = { fg = "#cba6f7" },
        NormalFloat = { bg = "#1e1e2e" },
        -- snacks
        SnacksPickerPrompt = { fg = "#cba6f7" },
        SnacksPickerTerminalTitle = { fg = "#1e1e2e", bg = "#94e2d5" },
        SnacksPickerLazygitTitle = { fg = "#1e1e2e", bg = "#f38ba8" },

        SnacksPickerTitle = { fg = "#1e1e2e", bg = "#cba6f7" },
        SnacksPickerListCursorLine = { bg = "#313244" },

        SnacksPickerPreview = { bg = "#181825" },
        SnacksPickerPreviewTitle = { fg = "#1e1e2e", bg = "#a6e3a1" },
        SnacksPickerPreviewBorder = { fg = "#181825", bg = "#181825" },

        -- CursorMoved url
        HighlightCursorUrl = { bg = nil, fg = "#f38ba8" },
        -- TreesitterContext
        TreesitterContextLineNumber = { fg = "#6c7086", bg = "#1e1e2e" },
        TreesitterContextBottom = { bg = "#313244" },
        -- statusline
        StatusLine = { fg = "#cba6f7" },
        -- noice
        NoiceCmdlineIcon = { fg = "#b4befe" },
        NoiceCmdlinePopupBorder = { fg = "#cba6f7" },
        -- blink
        BlinkCmpMenu = { bg = "#1e1e2e" },
        BlinkCmpMenuBorder = { fg = "#cba6f7" },
        BlinkCmpDoc = { bg = "#1e1e2e" },
        BlinkCmpDocBorder = { fg = "#cba6f7" },
        BlinkCmpDocSeparator = { fg = "#cba6f7", bg = "#1e1e2e" },
        BlinkCmpScrollBarThumb = { bg = "#cba6f7" },
        BlinkCmpMenuSelection = { bg = "#313244" },
        -- which_key
        WhichKey = { fg = "#a6adc8", bg = "#1e1e2e" },
        WhichKeyNormal = { fg = "#cba6f7", bg = "#1e1e2e" },
        WhichKeyTitle = { fg = "#cba6f7" },
        -- avante
        AvanteInlineHint = { fg = "#94e2d5" },
        AvanteSidebar = { bg = "#181825" },
        AvanteSidebarNormal = { bg = "#181825" },
        AvanteSidebarWinSeparator = { fg = "#181825", bg = "#181825" },
        AvanteSidebarWinHorizontalSeparator = { fg = "#11111b", bg = "#181825" },
        AvantePopupHint = { fg = "#cba6f7", bg = "#181825" },
        AvanteTitle = { bg = "#a6e3a1", fg = "#1e1e2e" },
        AvanteSubtitle = { bg = "#94e2d5", fg = "#1E1E2E" },
        AvanteThirdTitle = { bg = "#313244", fg = "#a6adc8" },

        -- edgy
        EdgyNormal = { bg = "#181825", fg = "#a6adc8" },
        EdgyTitle = { bold = true, cterm = { bold = true }, fg = "#1E1E2E", bg = "#cba6f7" },
      },
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
