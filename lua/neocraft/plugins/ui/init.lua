return {

	-- This is what powers NeoCraft's fancy-looking
	-- tabs, which include filetype icons and close buttons.
	{
		"akinsho/bufferline.nvim",
		event = "VeryLazy",
		keys = {
			{ "<S-Tab>", "<cmd>BufferLineCyclePrev<cr>", desc = "Prev Buffer" },
			{ "<Tab>", "<cmd>BufferLineCycleNext<cr>", desc = "Next Buffer" },
		},
		opts = {
			options = {
				mode = "tabs",
				diagnostics = "nvim_lsp",
				always_show_bufferline = false,
				diagnostics_indicator = function(_, _, diag)
					local icons = NeoCraft.config.icons.diagnostics
					local ret = (diag.error and icons.Error .. diag.error .. " " or "")
					-- .. (diag.warning and icons.Warn .. diag.warning or "")
					return vim.trim(ret)
				end,
				offsets = {
					{
						filetype = "snacks_layout_box",
					},
				},
				---@param opts bufferline.IconFetcherOpts
				get_element_icon = function(opts)
					return NeoCraft.config.icons.ft[opts.filetype]
				end,
				show_buffer_close_icons = false,
				show_close_icon = false,
			},
		},
		config = function(_, opts)
			require("bufferline").setup(opts)
			-- Fix bufferline when restoring a session
			vim.api.nvim_create_autocmd({ "BufAdd", "BufDelete" }, {
				callback = function()
					vim.schedule(function()
						pcall(nvim_bufferline)
					end)
				end,
			})
		end,
	},

	-- Highly experimental plugin that completely replaces the UI for messages, cmdline and the popupmenu.
	{
		"folke/noice.nvim",
		event = "VeryLazy",
		opts = {
			presets = {
				lsp_doc_border = true,
				command_palette = true,
				long_message_to_split = true,
			},
			lsp = {
				override = {
					["vim.lsp.util.convert_input_to_markdown_lines"] = true,
					["vim.lsp.util.stylize_markdown"] = true,
				},
				-- signature = { enabled = false }, -- Handled by blink
			},
			routes = {
				{
					filter = {
						event = "msg_show",
						any = {
							{ find = "%d+L, %d+B" },
							{ find = "; after #%d+" },
							{ find = "; before #%d+" },
							{ find = '"*"*lines --*%--' },
						},
					},
					opts = { skip = true },
				},
				{
					filter = {
						any = {
							{ event = "msg_show" },
							{ event = "notify" },
							{ event = "noice" },
							{ event = "lsp", kind = "message" },
						},
					},
					view = "mini",
				},
			},
		},
    -- stylua: ignore
    keys = {
      { "<leader>n", "", desc = "+noice"},
      { "<S-Enter>", function() require("noice").redirect(vim.fn.getcmdline()) end, mode = "c", desc = "Redirect Cmdline" },
      { "<leader>nl", function() require("noice").cmd("last") end, desc = "Noice Last Message" },
      { "<leader>nh", function() require("noice").cmd("history") end, desc = "Noice History" },
      { "<leader>na", function() require("noice").cmd("all") end, desc = "Noice All" },
      { "<leader>nd", function() require("noice").cmd("dismiss") end, desc = "Dismiss All" },
      { "<leader>nt", function() require("noice").cmd("pick") end, desc = "Noice Picker (Telescope/FzfLua)" },
      { "<c-f>", function() if not require("noice.lsp").scroll(4) then return "<c-f>" end end, silent = true, expr = true, desc = "Scroll Forward", mode = {"i", "n", "s"} },
      { "<c-b>", function() if not require("noice.lsp").scroll(-4) then return "<c-b>" end end, silent = true, expr = true, desc = "Scroll Backward", mode = {"i", "n", "s"}},
    },
		config = function(_, opts)
			-- HACK: noice shows messages from before it was enabled,
			-- but this is not ideal when Lazy is installing plugins,
			-- so clear the messages in this case.
			if vim.o.filetype == "lazy" then
				vim.cmd([[messages clear]])
			end
			require("noice").setup(opts)
		end,
	},

	-- icons
	{
		"echasnovski/mini.icons",
		lazy = true,
		opts = {
			file = {
				[".keep"] = { glyph = "󰊢", hl = "MiniIconsGrey" },
				["devcontainer.json"] = { glyph = "", hl = "MiniIconsAzure" },
			},
			filetype = {
				dotenv = { glyph = "", hl = "MiniIconsYellow" },
			},
		},
		init = function()
			package.preload["nvim-web-devicons"] = function()
				require("mini.icons").mock_nvim_web_devicons()
				return package.loaded["nvim-web-devicons"]
			end
		end,
	},

	-- ui components
	{ "MunifTanjim/nui.nvim", lazy = true },

	{
		"snacks.nvim",
		opts = {
			indent = { enabled = true },
			input = { enabled = true },
			notifier = { enabled = true },
			scope = { enabled = true },
			scroll = { enabled = true },
			statuscolumn = { enabled = false }, -- we set this in options.lua
			toggle = { map = NeoCraft.safe_keymap_set },
			words = { enabled = true },
		},
    -- stylua: ignore
    keys = {
      { "<space>n", function()
        if Snacks.config.picker and Snacks.config.picker.enabled then
          Snacks.picker.notifications()
        else
          Snacks.notifier.show_history()
        end
      end, desc = "Notification History" },
      { "<leader>un", function() Snacks.notifier.hide() end, desc = "Dismiss All Notifications" },
    },
	},

	-- import ui
	{ import = "neocraft.plugins.ui" },
}
