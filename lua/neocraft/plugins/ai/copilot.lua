return {
	{
		"CopilotC-Nvim/CopilotChat.nvim",
		-- enabled = false,
		branch = "main",
		cmd = "CopilotChat",
		opts = function()
			local user = vim.env.USER or "Neo"
			return {
				auto_insert_mode = true,
				question_header = "  " .. user .. " ",
				answer_header = "  Copilot ",
				error_header = "  Error ",
				window = {
					width = 0.4,
				},
				mappings = {
					reset = {
						normal = "<C-x>",
						insert = "<C-x>",
					},
				},
			}
		end,
		keys = {
			{
				"<space>c",
				function()
					vim.ui.input({
						prompt = "Quick Chat: ",
					}, function(input)
						if input ~= "" then
							require("CopilotChat").ask(input)
						end
					end)
				end,
				desc = "Quick Chat (CopilotChat)",
				mode = { "n", "v" },
			},
			{
				"<space>a",
				function()
					return require("CopilotChat").toggle()
				end,
				desc = "Toggle (CopilotChat)",
				mode = { "n", "v" },
			},

			{ "<c-s>", "<CR>", ft = "copilot-chat", desc = "Submit Prompt", remap = true },
			{ "<leader>a", "", desc = "+ai", mode = { "n", "v" } },
			{
				"<leader>ax",
				function()
					return require("CopilotChat").reset()
				end,
				desc = "Clear (CopilotChat)",
				mode = { "n", "v" },
			},
			{
				"<leader>ap",
				function()
					require("CopilotChat").select_prompt()
				end,
				desc = "Prompt Actions (CopilotChat)",
				mode = { "n", "v" },
			},
		},
		config = function(_, opts)
			local chat = require("CopilotChat")

			vim.api.nvim_create_autocmd("BufEnter", {
				pattern = "copilot-chat",
				callback = function()
					vim.opt_local.relativenumber = false
					vim.opt_local.number = false
				end,
			})

			chat.setup(opts)
		end,
	},

	{
		"MeanderingProgrammer/render-markdown.nvim",
		optional = true,
		opts = {
			file_types = { "copilot-chat" },
		},
		ft = { "copilot-chat" },
	},
	--  more granular control over adding sources by filetype
	{
		"saghen/blink.cmp",
		optional = true,
		opts = {
			sources = {
				per_filetype = {
					["copilot-chat"] = {},
				},
			},
		},
	},
}
