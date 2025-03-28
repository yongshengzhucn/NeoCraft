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
				FloatBorder = { fg = "#585b70" },
				-- hl snacks
				SnacksPickerPrompt = { fg = "#f9e2af" },
				-- hl CursorMoved url
				HighlightCursorUrl = { bg = nil, fg = "#f38ba8" },
				-- hl TreesitterContext
				TreesitterContextLineNumberBottom = { bg = "#1e1e2e" },
				TreesitterContextLineNumber = { fg = "#6c7086", bg = "#1e1e2e" },
				TreesitterContext = { bg = "#1e1e2e" },
				TreesitterContextBottom = { bg = "#313244" },
				--hl statusline
				StatusLine = { fg = "#fab387" },
				--hl noice
				NoiceCmdlineIcon = { fg = "#94e2d5" },
				NoiceCmdlinePopupBorder = { fg = "#585b70" },
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
