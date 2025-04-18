return {
	{
		"akinsho/toggleterm.nvim",
		event = "VeryLazy",
		opts = {--[[ things you want to change go here]]
			open_mapping = [[<c-/>]],
			direction = "float",
			float_opts = {
				border = "curved",
				width = function()
					return math.floor(vim.o.columns * 0.75)
				end,
				height = function()
					return math.floor(vim.o.lines * 0.75)
				end,
				winblend = 4,
				zindex = 54,
			},
			highlights = {
				FloatBorder = {
					guifg = "#cba6f7",
					guibg = "#1E1E2E",
				},
			},
		},
	},
}
