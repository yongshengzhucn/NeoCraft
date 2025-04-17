return {
	{
		"yetone/avante.nvim",
		-- enabled = false,
		event = "VeryLazy",
		lazy = false,
		version = false, -- set this if you want to always pull the latest change
		opts = {
			provider = "ollama",
			ollama = {
				endpoint = "http://127.0.0.1:11434",
				model = "qwen2.5-coder:32b",
			},

			behaviour = {
				auto_suggestions = false, -- Experimental stage
				auto_set_highlight_group = true,
				auto_set_keymaps = true,
				auto_apply_diff_after_generation = false,
				support_paste_from_clipboard = true,
			},
			mappings = {
				--- @class AvanteConflictMappings
				diff = {
					ours = "co",
					theirs = "ct",
					all_theirs = "ca",
					both = "cb",
					cursor = "cc",
					next = "]x",
					prev = "[x",
				},
				suggestion = {
					accept = "<M-l>",
					next = "<M-]>",
					prev = "<M-[>",
					dismiss = "<C-]>",
				},
				jump = {
					next = "]]",
					prev = "[[",
				},
				submit = {
					normal = "<CR>",
					insert = "<C-s>",
				},
			},
			hints = { enabled = true },
			windows = {
				---@type "right" | "left" | "top" | "bottom"
				position = "right", -- the position of the sidebar
				wrap = true, -- similar to vim.o.wrap
				width = 40, -- default % based on available width
				sidebar_header = {
					align = "center", -- left, center, right for title
					rounded = true,
				},
			},
			highlights = {
				---@type AvanteConflictHighlights
				diff = {
					current = "DiffText",
					incoming = "DiffAdd",
				},
			},
			--- @class AvanteConflictUserConfig
			diff = {
				autojump = true,
				---@type string | fun(): any
				list_opener = "copen",
			},
		},
		-- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
		build = "make BUILD_FROM_SOURCE=true",
		-- build = "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false" -- for windows
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
			"stevearc/dressing.nvim",
			"nvim-lua/plenary.nvim",
			"MunifTanjim/nui.nvim",
			--- The below dependencies are optional,
			"echasnovski/mini.icons",
			{
				-- support for image pasting
				"HakonHarnes/img-clip.nvim",
				event = "VeryLazy",
				opts = {
					-- recommended settings
					default = {
						embed_image_as_base64 = false,
						prompt_for_file_name = false,
						drag_and_drop = {
							insert_mode = true,
						},
						-- required for Windows users
						use_absolute_path = true,
					},
				},
			},
			{
				-- Make sure to set this up properly if you have lazy=true
				"MeanderingProgrammer/render-markdown.nvim",
				opts = {
					file_types = { "markdown", "Avante" },
				},
				ft = { "markdown", "Avante" },
			},
		},
		keys = {
			{
				"<space>a",
				function()
					require("avante.api").toggle()
				end,
				desc = "avante: toggle",
				mode = { "n", "v" },
			},
			{ "<leader>a", "", desc = "+ai", mode = { "n", "v" } },
			{
				"<leader>ar",
				function()
					require("avante.api").refresh()
				end,
				desc = "avante: refresh",
			},
			{
				"<leader>ae",
				function()
					require("avante.api").edit()
				end,
				desc = "avante: edit",
				mode = "v",
			},
		},
	},
	{
		"saghen/blink.cmp",
		optional = true,
		dependencies = {
			{
				"saghen/blink.compat",
				config = function()
					-- monkeypatch cmp.ConfirmBehavior for Avante
					require("cmp").ConfirmBehavior = {
						Insert = "insert",
						Replace = "replace",
					}
				end,
			},
		},
		opts = {
			sources = {
				default = { "avante_commands", "avante_mentions", "avante_files" },
				providers = {
					avante_commands = {
						name = "avante_commands",
						module = "blink.compat.source",
						min_keyword_length = function(ctx)
							if ctx.trigger.kind ~= "trigger_character" then
								return 10000
							end
							local row, col = unpack(vim.api.nvim_win_get_cursor(0))
							local line = vim.api.nvim_get_current_line()

							if col > 0 and line:sub(col, col) == "/" then
								if col == 1 or not line:sub(col - 1, col - 1):match("%w") then
									return 0
								end
							end
							return 10000
						end,
						opts = {},
					},
					avante_files = {
						name = "avante_files",
						module = "blink.compat.source",
						min_keyword_length = function(ctx)
							if ctx.trigger.kind ~= "trigger_character" then
								return 10000
							end
							local row, col = unpack(vim.api.nvim_win_get_cursor(0))
							local line = vim.api.nvim_get_current_line()

							if col > 0 and line:sub(col, col) == "/" then
								if col == 1 or not line:sub(col - 1, col - 1):match("%w") then
									return 0
								end
							end
							return 10000
						end,
						opts = {},
					},
					avante_mentions = {
						name = "avante_mentions",
						module = "blink.compat.source",
						min_keyword_length = function(ctx)
							if ctx.trigger.kind ~= "trigger_character" then
								return 10000
							end
							local row, col = unpack(vim.api.nvim_win_get_cursor(0))
							local line = vim.api.nvim_get_current_line()

							if col > 0 and line:sub(col, col) == "@" then
								if col == 1 or not line:sub(col - 1, col - 1):match("%w") then
									return 0
								end
							end
							return 10000
						end,
						opts = {},
					},
				},
				per_filetype = {
					AvanteInput = {
						"avante_commands",
						"avante_mentions",
						"avante_files",
					},
				},
			},
		},
	},
}
