return {

	---TODO: ft_color change with git status
	{
		"b0o/incline.nvim",
		dependencies = {},
		event = "VeryLazy",
		config = function()
			local function process_path(path)
				local home_dir = vim.api.nvim_eval('expand("~")')
				-- special case for oil
				if string.find(path, home_dir) then
					path = path:gsub(home_dir, "~")
				end
				return path
			end
			local helpers = require("incline.helpers")
			require("incline").setup({
				window = {
					placement = {
						vertical = "top",
						horizontal = "right",
					},
					padding = 0,
					margin = { horizontal = 0 },
				},
				render = function(props)
					local relative_path = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(props.buf), ":~:.:h")
					relative_path = string.gsub(relative_path, "^oil://", "")
					local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(props.buf), ":t")
					local mini_icons = require("mini.icons")
					local ft_icon, ft_hl = (filename and #filename > 0) and mini_icons.get("extension", filename)
						or mini_icons.get("directory", relative_path)
					local ft_color = vim.api.nvim_get_hl(0, { name = ft_hl }).guifg
					local modified = vim.bo[props.buf].modified
					local separator = (filename and #filename > 0) and "/" or ""
					local buffer = {
						{ (ft_icon or ""), guifg = ft_color, guibg = "none" },
						-- ft_icon and { " ", ft_icon, " ", guibg = ft_color, guifg = helpers.contrast_color(ft_color) } or "",
						" ",
						{
							relative_path and process_path(relative_path) .. separator,
							guifg = ft_color,
							guibg = "none",
						},
						{
							filename,
							gui = modified and "bold,italic" or "bold",
							guifg = modified and "#f38ba8" or "#fab387",
						},
						" ",
						guibg = "#1e1e2e",
					}
					return buffer
				end,
			})
		end,
	},
}
