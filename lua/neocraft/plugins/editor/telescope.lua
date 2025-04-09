local build_cmd ---@type string?
for _, cmd in ipairs({ "make", "cmake", "gmake" }) do
	if vim.fn.executable(cmd) == 1 then
		build_cmd = cmd
		break
	end
end

---@type LazyPicker
local picker = {
	name = "telescope",
	commands = {
		files = "find_files",
	},
	-- this will return a function that calls telescope.
	-- cwd will default to neocraft.util.get_root
	-- for `files`, git_files or find_files will be chosen depending on .git
	---@param builtin string
	---@param opts? neocraft.util.pick.Opts
	open = function(builtin, opts)
		opts = opts or {}
		opts.follow = opts.follow ~= false
		if opts.cwd and opts.cwd ~= vim.uv.cwd() then
			local function open_cwd_dir()
				local action_state = require("telescope.actions.state")
				local line = action_state.get_current_line()
				NeoCraft.pick.open(
					builtin,
					vim.tbl_deep_extend("force", {}, opts or {}, {
						root = false,
						default_text = line,
					})
				)
			end
			---@diagnostic disable-next-line: inject-field
			opts.attach_mappings = function(_, map)
				-- opts.desc is overridden by telescope, until it's changed there is this fix
				map("i", "<a-c>", open_cwd_dir, { desc = "Open cwd Directory" })
				return true
			end
		end

		require("telescope.builtin")[builtin](opts)
	end,
}
if not NeoCraft.pick.register(picker) then
	return {}
end

return {
	-- Fuzzy finder.
	-- The default key bindings to find files will use Telescope's
	-- `find_files` or `git_files` depending on whether the
	-- directory is a git repo.
	{
		"nvim-telescope/telescope.nvim",
		cmd = "Telescope",
		version = false, -- telescope did only one release, so use HEAD for now
		dependencies = {
			{
				"nvim-telescope/telescope-fzf-native.nvim",
				build = (build_cmd ~= "cmake") and "make"
					or "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build",
				enabled = build_cmd ~= nil,
				config = function(plugin)
					NeoCraft.on_load("telescope.nvim", function()
						local ok, err = pcall(require("telescope").load_extension, "fzf")
						if not ok then
							local lib = plugin.dir .. "/build/libfzf." .. (NeoCraft.is_win() and "dll" or "so")
							if not vim.uv.fs_stat(lib) then
								NeoCraft.warn("`telescope-fzf-native.nvim` not built. Rebuilding...")
								require("lazy").build({ plugins = { plugin }, show = false }):wait(function()
									NeoCraft.info(
										"Rebuilding `telescope-fzf-native.nvim` done.\nPlease restart Neovim."
									)
								end)
							else
								NeoCraft.error("Failed to load `telescope-fzf-native.nvim`:\n" .. err)
							end
						end
					end)
				end,
			},
			-- file browser
			{
				"nvim-telescope/telescope-file-browser.nvim",
				config = function()
					NeoCraft.on_load("telescope.nvim", function()
						local actions = require("telescope.actions")
						local fb_actions = require("telescope").extensions.file_browser.actions

						require("telescope").setup({
							extensions = {
								file_browser = {
									theme = "dropdown",
									-- disables netrw and use telescope-file-browser in its place
									hijack_netrw = true,
									mappings = {
										-- your custom insert mode mappings
										["n"] = {
											-- your custom normal mode mappings
											["N"] = fb_actions.create,
											["h"] = fb_actions.goto_parent_dir,
											["<C-u>"] = function(prompt_bufnr)
												for i = 5, 10 do
													actions.move_selection_previous(prompt_bufnr)
												end
											end,
											["<C-d>"] = function(prompt_bufnr)
												for i = 5, 10 do
													actions.move_selection_next(prompt_bufnr)
												end
											end,
										},
									},
								},
							},
						})
						require("telescope").load_extension("file_browser")
					end)
				end,
			},
			-- undo
			{
				"debugloop/telescope-undo.nvim",
				config = function()
					NeoCraft.on_load("telescope.nvim", function()
						require("telescope").setup({
							extensions = {
								undo = {
									theme = "ivy",
								},
							},
						})
						require("telescope").load_extension("undo")
					end)
				end,
			},
		},
		keys = {
			{ "<Space>u", "<cmd>Telescope undo<cr>", desc = "Telescope undo" },
			{
				"<Space><Space>",
				function()
					local telescope = require("telescope")

					local function telescope_buffer_dir()
						if vim.bo.filetype == "oil" then
							local prefix = "oil://"
							return vim.fn.expand("%:p:h"):sub(#prefix + 1)
						end
						return vim.fn.expand("%:p:h")
					end

					telescope.extensions.file_browser.file_browser({
						path = telescope_buffer_dir(),
						respect_gitignore = false,
						hidden = true,
						grouped = true,
						previewer = false,
						initial_mode = "normal",
						-- layout_config = { height = 36 },
					})
				end,
				desc = "Open File Browser(current buffer path)",
			},
			{ "<space>r", "<cmd>Telescope oldfiles<cr>", desc = "Recent" },
			{ "<space>h", "<cmd>Telescope help_tags<cr>", desc = "Help Pages" },
			{
				"<leader>,",
				"<cmd>Telescope buffers sort_mru=true sort_lastused=true<cr>",
				desc = "Switch Buffer",
			},
			{ "<leader>/", NeoCraft.pick("live_grep"), desc = "Grep (Root Dir)" },
			{ "<leader>:", "<cmd>Telescope command_history<cr>", desc = "Command History" },
			{ "<leader><space>", NeoCraft.pick("files"), desc = "Find Files (Root Dir)" },
			--find
			{ "<leader>fc", NeoCraft.pick.config_files(), desc = "Find Config File" },
			{ "<leader>ff", NeoCraft.pick("files"), desc = "Find Files (Root Dir)" },
			-- { "<leader>fF", NeoCraft.pick("files", { root = false }), desc = "Find Files (cwd)" },
			{ "<leader>fg", "<cmd>Telescope git_files<cr>", desc = "Find Files (git-files)" },
			{ "<leader>fr", "<cmd>Telescope oldfiles<cr>", desc = "Recent" },
			-- git
			{ "<leader>gc", "<cmd>Telescope git_commits<CR>", desc = "Commits" },
			{ "<leader>gs", "<cmd>Telescope git_status<CR>", desc = "Status" },
			-- search
			{ "<leader>sa", "<cmd>Telescope autocommands<cr>", desc = "Auto Commands" },
			{ "<leader>sb", "<cmd>Telescope current_buffer_fuzzy_find<cr>", desc = "Buffer" },
			{ "<leader>sc", "<cmd>Telescope commands<cr>", desc = "Commands" },
			{ "<leader>sd", "<cmd>Telescope diagnostics bufnr=0<cr>", desc = "Document Diagnostics" },
			{ "<leader>sD", "<cmd>Telescope diagnostics<cr>", desc = "Workspace Diagnostics" },
			{ "<leader>sh", "<cmd>Telescope help_tags<cr>", desc = "Help Pages" },
			{ "<leader>sH", "<cmd>Telescope highlights<cr>", desc = "Search Highlight Groups" },
			{ "<leader>sj", "<cmd>Telescope jumplist<cr>", desc = "Jumplist" },
			{ "<leader>sk", "<cmd>Telescope keymaps<cr>", desc = "Key Maps" },
			{ "<leader>sl", "<cmd>Telescope loclist<cr>", desc = "Location List" },
			{ "<leader>sM", "<cmd>Telescope man_pages<cr>", desc = "Man Pages" },
			{ "<leader>sm", "<cmd>Telescope marks<cr>", desc = "Jump to Mark" },
			{ "<leader>so", "<cmd>Telescope vim_options<cr>", desc = "Options" },
			{ "<leader>sR", "<cmd>Telescope resume<cr>", desc = "Resume" },
			{ "<leader>sq", "<cmd>Telescope quickfix<cr>", desc = "Quickfix List" },
			{ "<leader>sw", NeoCraft.pick("grep_string", { word_match = "-w" }), desc = "Word (Root Dir)" },
			-- { "<leader>sW", NeoCraft.pick("grep_string", { root = false, word_match = "-w" }), desc = "Word (cwd)" },
			{ "<leader>sw", NeoCraft.pick("grep_string"), mode = "v", desc = "Selection (Root Dir)" },
			-- { "<leader>sW", NeoCraft.pick("grep_string", { root = false }), mode = "v", desc = "Selection (cwd)" },
			{
				"<leader>ss",
				function()
					require("telescope.builtin").lsp_document_symbols({
						symbols = NeoCraft.config.get_kind_filter(),
					})
				end,
				desc = "Goto Symbol",
			},
			{
				"<leader>sS",
				function()
					require("telescope.builtin").lsp_dynamic_workspace_symbols({
						symbols = NeoCraft.config.get_kind_filter(),
					})
				end,
				desc = "Goto Symbol (Workspace)",
			},
		},
		opts = function()
			local actions = require("telescope.actions")
			local layout = require("telescope.actions.layout")

			local open_with_trouble = function(...)
				return require("trouble.sources.telescope").open(...)
			end
			local find_files_no_ignore = function()
				local action_state = require("telescope.actions.state")
				local line = action_state.get_current_line()
				NeoCraft.pick("find_files", { no_ignore = true, default_text = line })()
			end
			local find_files_with_hidden = function()
				local action_state = require("telescope.actions.state")
				local line = action_state.get_current_line()
				NeoCraft.pick("find_files", { hidden = true, default_text = line })()
			end

			local function find_command()
				if 1 == vim.fn.executable("rg") then
					return { "rg", "--files", "--color", "never", "-g", "!.git" }
				elseif 1 == vim.fn.executable("fd") then
					return { "fd", "--type", "f", "--color", "never", "-E", ".git" }
				elseif 1 == vim.fn.executable("fdfind") then
					return { "fdfind", "--type", "f", "--color", "never", "-E", ".git" }
				elseif 1 == vim.fn.executable("find") and vim.fn.has("win32") == 0 then
					return { "find", ".", "-type", "f" }
				elseif 1 == vim.fn.executable("where") then
					return { "where", "/r", ".", "*" }
				end
			end
			return {
				defaults = {
					prompt_prefix = "  ",
					selection_caret = "  ",
					wrap_results = true,
					layout_strategy = "horizontal",
					layout_config = { prompt_position = "top" },
					sorting_strategy = "ascending",
					winblend = 4,

					-- open files in the first window that is an actual file.
					-- use the current window if no other window is available.
					get_selection_window = function()
						local wins = vim.api.nvim_list_wins()
						table.insert(wins, 0, vim.api.nvim_get_current_win())
						for _, win in ipairs(wins) do
							local buf = vim.api.nvim_win_get_buf(win)
							if vim.bo[buf].buftype == "" then
								return win
							end
						end
						return 0
					end,
					path_display = { "filename_first" },
					mappings = {
						i = {
							["<c-t>"] = open_with_trouble,
							["<a-t>"] = open_with_trouble,
							["<a-i>"] = find_files_no_ignore,
							["<a-h>"] = find_files_with_hidden,
							["<C-Down>"] = actions.cycle_history_next,
							["<C-Up>"] = actions.cycle_history_prev,
							["<C-f>"] = actions.preview_scrolling_down,
							["<C-p>"] = layout.toggle_preview,
							["<C-b>"] = actions.move_selection_previous,
						},
						n = {
							["q"] = actions.close,
							["<C-p>"] = layout.toggle_preview,
							["<C-b>"] = actions.move_selection_previous,
						},
					},
				},
				pickers = {
					find_files = {
						theme = "dropdown",
						find_command = find_command,
						previewer = false,
					},
					buffers = {
						theme = "dropdown",
						previewer = false,
					},
					oldfiles = {
						theme = "dropdown",
						previewer = false,
					},
					live_grep = {
						theme = "ivy",
						-- previewer = false,
					},
					git_files = {
						theme = "dropdown",
						previewer = false,
					},
					commands = {
						theme = "ivy",
						previewer = false,
					},
					command_history = {
						theme = "ivy",
						previewer = false,
					},
					autocommands = {
						theme = "ivy",
						previewer = false,
					},
					grep_string = {
						theme = "ivy",
						previewer = true,
					},
					git_commits = {
						theme = "dropdown",
						previewer = false,
					},
					git_status = {
						theme = "dropdown",
						previewer = false,
					},
					registers = {
						theme = "dropdown",
						previewer = false,
					},
					current_buffer_fuzzy_find = {
						theme = "dropdown",
						previewer = false,
					},
					help_tags = {
						theme = "dropdown",
						previewer = false,
					},
					highlights = {
						theme = "ivy",
						previewer = true,
					},
					keymaps = {
						theme = "ivy",
						previewer = false,
					},
					man_pages = {
						theme = "dropdown",
						previewer = false,
					},
					marks = {
						theme = "ivy",
						-- previewer = false,
					},
					vim_options = {
						theme = "ivy",
						previewer = false,
					},
					colorscheme = {
						theme = "ivy",
						previewer = false,
					},
					lsp_document_symbols = {
						theme = "dropdown",
						previewer = false,
					},
					lsp_dynamic_workspace_symbols = {
						theme = "dropdown",
						previewer = false,
					},
					lsp_references = {
						theme = "ivy",
						-- previewer = false,
					},
					lsp_implementations = {
						theme = "ivy",
						-- previewer = false,
					},
					lsp_definitions = {
						theme = "ivy",
						-- previewer = false,
					},
					lsp_type_definitions = {
						theme = "ivy",
						-- previewer = false,
					},
					pickers = {
						theme = "ivy",
						previewer = false,
					},

					diagnostics = {
						theme = "ivy",
						initial_mode = "normal",
						layout_config = {
							preview_cutoff = 10003,
						},
					},
				},
			}
		end,
	},

	-- Flash Telescope config
	{
		"nvim-telescope/telescope.nvim",
		optional = true,
		opts = function(_, opts)
			if not NeoCraft.has("flash.nvim") then
				return
			end
			local function flash(prompt_bufnr)
				require("flash").jump({
					pattern = "^",
					label = { after = { 0, 0 } },
					search = {
						mode = "search",
						exclude = {
							function(win)
								return vim.bo[vim.api.nvim_win_get_buf(win)].filetype ~= "TelescopeResults"
							end,
						},
					},
					action = function(match)
						local picker = require("telescope.actions.state").get_current_picker(prompt_bufnr)
						picker:set_selection(match.pos[1] - 1)
					end,
				})
			end
			opts.defaults = vim.tbl_deep_extend("force", opts.defaults or {}, {
				mappings = { n = { s = flash }, i = { ["<c-s>"] = flash } },
			})
		end,
	},

	{
		"neovim/nvim-lspconfig",
		opts = function()
			local Keys = require("neocraft.plugins.lsp.keymaps").get()
      -- stylua: ignore
      vim.list_extend(Keys, {
        { "gd", function() require("telescope.builtin").lsp_definitions({ reuse_win = true }) end, desc = "Goto Definition", has = "definition" },
        { "gr", "<cmd>Telescope lsp_references<cr>", desc = "References", nowait = true },
        { "gI", function() require("telescope.builtin").lsp_implementations({ reuse_win = true }) end, desc = "Goto Implementation" },
        { "gy", function() require("telescope.builtin").lsp_type_definitions({ reuse_win = true }) end, desc = "Goto T[y]pe Definition" },
      })
		end,
	},
}
