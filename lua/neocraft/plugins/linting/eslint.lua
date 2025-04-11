local auto_format = vim.g.neocraft_eslint_auto_format == nil or vim.g.neocraft_eslint_auto_format

return {
	{
		"neovim/nvim-lspconfig",
		-- other settings removed for brevity
		opts = {
			---@type lspconfig.options
			servers = {
				eslint = {
					settings = {
						-- helps eslint find the eslintrc when it's placed in a subfolder instead of the cwd root
						workingDirectories = { mode = "auto" },
						format = auto_format,
					},
				},
			},
			setup = {
				eslint = function()
					if not auto_format then
						return
					end

					local function get_client(buf)
						return NeoCraft.lsp.get_clients({ name = "eslint", bufnr = buf })[1]
					end

					local formatter = NeoCraft.lsp.formatter({
						name = "eslint: lsp",
						primary = false,
						priority = 200,
						filter = "eslint",
					})

					-- register the formatter with NeoCraft
					NeoCraft.format.register(formatter)
				end,
			},
		},
	},
}
