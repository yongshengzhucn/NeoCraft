local lsp = vim.g.neocraft_python_lsp or "pyright"
local ruff = vim.g.neocraft_python_ruff or "ruff"

return {
	{
		"nvim-treesitter/nvim-treesitter",
		opts = { ensure_installed = { "ninja", "rst" } },
	},
	{
		"neovim/nvim-lspconfig",
		opts = {
			servers = {
				ruff = {
					cmd_env = { RUFF_TRACE = "messages" },
					init_options = {
						settings = {
							logLevel = "error",
						},
					},
					keys = {
						{
							"<leader>co",
							NeoCraft.lsp.action["source.organizeImports"],
							desc = "Organize Imports",
						},
					},
				},
				ruff_lsp = {
					keys = {
						{
							"<leader>co",
							NeoCraft.lsp.action["source.organizeImports"],
							desc = "Organize Imports",
						},
					},
				},
			},
			setup = {
				[ruff] = function()
					NeoCraft.lsp.on_attach(function(client, _)
						-- Disable hover in favor of Pyright
						client.server_capabilities.hoverProvider = false
					end, ruff)
				end,
			},
		},
	},
	{
		"neovim/nvim-lspconfig",
		opts = function(_, opts)
			local servers = { "pyright", "basedpyright", "ruff", "ruff_lsp", ruff, lsp }
			for _, server in ipairs(servers) do
				opts.servers[server] = opts.servers[server] or {}
				opts.servers[server].enabled = server == lsp or server == ruff
			end
		end,
	},
	{
		"mfussenegger/nvim-dap",
		optional = true,
		dependencies = {
			{
				"williamboman/mason.nvim",
				opts = { ensure_installed = { "debugpy" } },
			},
			{
				"mfussenegger/nvim-dap-python",
        -- stylua: ignore
        keys = {
          { "<leader>dxt", function() require('dap-python').test_method() end, desc = "Debug Method", ft = "python" },
          { "<leader>dxc", function() require('dap-python').test_class() end, desc = "Debug Class", ft = "python" },
        },
				config = function()
					require("dap-python").setup(NeoCraft.get_pkg_path("debugpy", "/venv/bin/python"))
				end,
			},
		},
	},

	{
		"yongshengzhucn/venv-selector",
		branch = "regexp", -- Use this branch for the new version
		dev = true,
		cmd = "VenvSelect",
		enabled = function()
			return NeoCraft.has("telescope.nvim")
		end,
		opts = {
			settings = {
				options = {
					-- picker = "native",
					notify_user_on_venv_activation = true,
					telescope_active_venv_color = "#a6e3a1",
					on_venv_activate_callback = function()
						-- Shell tools like Starship have access to the same shell environment.
						-- They can simply read these well-defined variables (CONDA_PREFIX, CONDA_DEFAULT_ENV) to determine the state.
						local venv = require("venv-selector").venv()
						local conda_venv_dir = "/opt/anaconda3/envs"
						venv = venv:sub(#conda_venv_dir + 2)
						vim.fn.setenv("CONDA_DEFAULT_ENV", venv)
						-- A value greater than 0 indicates an active Conda environment.
						vim.fn.setenv("CONDA_SHLVL", 1)
					end,
				},
				search = {
					anaconda_envs = {
						command = "$FD 'bin/python$' /opt/anaconda3/envs --full-path --color never -E /proc",
						type = "anaconda",
					},
					anaconda_base = {
						command = "$FD '/python$' /opt/anaconda3/bin --full-path --color never -E /proc",
						type = "anaconda",
					},
				},
			},
		},
		--  Call config for python files and load the cached venv automatically
		ft = "python",
		keys = { { "<leader>cv", "<cmd>:VenvSelect<cr>", desc = "Select Python VirtualEnv", ft = "python" } },
	},

	-- Don't mess up DAP adapters provided by nvim-dap-python
	{
		"jay-babu/mason-nvim-dap.nvim",
		optional = true,
		opts = {
			handlers = {
				python = function() end,
			},
		},
	},
}
