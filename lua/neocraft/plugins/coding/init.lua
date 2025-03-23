return {
	-- auto pairs
	{
		"windwp/nvim-autopairs",
		event = "InsertEnter",
		opts = {
			check_ts = true,
		},
		config = function(_, opts)
			local npairs = require("nvim-autopairs")
			local Rule = require("nvim-autopairs.rule")
			local cond = require("nvim-autopairs.conds")
			npairs.setup(opts)

			-- Add spaces between parentheses

			local brackets = { { "(", ")" }, { "[", "]" }, { "{", "}" } }
			npairs.add_rules({
				-- Rule for a pair with left-side ' ' and right side ' '
				Rule(" ", " ")
					-- Pair will only occur if the conditional function returns true
					:with_pair(function(opts)
						-- We are checking if we are inserting a space in (), [], or {}
						local pair = opts.line:sub(opts.col - 1, opts.col)
						return vim.tbl_contains({
							brackets[1][1] .. brackets[1][2],
							brackets[2][1] .. brackets[2][2],
							brackets[3][1] .. brackets[3][2],
						}, pair)
					end)
					:with_move(cond.none())
					:with_cr(cond.none())
					-- We only want to delete the pair of spaces when the cursor is as such: ( | )
					:with_del(
						function(opts)
							local col = vim.api.nvim_win_get_cursor(0)[2]
							local context = opts.line:sub(col - 1, col + 2)
							return vim.tbl_contains({
								brackets[1][1] .. "  " .. brackets[1][2],
								brackets[2][1] .. "  " .. brackets[2][2],
								brackets[3][1] .. "  " .. brackets[3][2],
							}, context)
						end
					),
			})

			-- For each pair of brackets we will add another rule
			for _, bracket in pairs(brackets) do
				npairs.add_rules({
					-- Each of these rules is for a pair with left-side '( ' and right-side ' )' for each bracket type
					Rule(bracket[1] .. " ", " " .. bracket[2])
						:with_pair(cond.none())
						:with_move(function(opts)
							return opts.char == bracket[2]
						end)
						:with_del(cond.none())
						:use_key(bracket[2])
						-- Removes the trailing whitespace that can occur without this
						:replace_map_cr(function(_)
							return "<C-c>2xi<CR><C-c>O"
						end),
				})
			end

			-- Move past commas and semicolons
			for _, punct in pairs({ ",", ";" }) do
				require("nvim-autopairs").add_rules({
					require("nvim-autopairs.rule")("", punct)
						:with_move(function(opts)
							return opts.char == punct
						end)
						:with_pair(function()
							return false
						end)
						:with_del(function()
							return false
						end)
						:with_cr(function()
							return false
						end)
						:use_key(punct),
				})
			end
		end,
	},

	-- comments
	{
		"folke/ts-comments.nvim",
		event = "VeryLazy",
		opts = {},
	},

	-- Better text-objects
	{
		"echasnovski/mini.ai",
		event = "VeryLazy",
		opts = function()
			local ai = require("mini.ai")
			return {
				n_lines = 500,
				custom_textobjects = {
					o = ai.gen_spec.treesitter({ -- code block
						a = { "@block.outer", "@conditional.outer", "@loop.outer" },
						i = { "@block.inner", "@conditional.inner", "@loop.inner" },
					}),
					f = ai.gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }), -- function
					c = ai.gen_spec.treesitter({ a = "@class.outer", i = "@class.inner" }), -- class
					t = { "<([%p%w]-)%f[^<%w][^<>]->.-</%1>", "^<.->().*()</[^/]->$" }, -- tags
					d = { "%f[%d]%d+" }, -- digits
					e = { -- Word with case
						{
							"%u[%l%d]+%f[^%l%d]",
							"%f[%S][%l%d]+%f[^%l%d]",
							"%f[%P][%l%d]+%f[^%l%d]",
							"^[%l%d]+%f[^%l%d]",
						},
						"^().*()$",
					},
					g = NeoCraft.mini.ai_buffer, -- buffer
					u = ai.gen_spec.function_call(), -- u for "Usage"
					U = ai.gen_spec.function_call({ name_pattern = "[%w_]" }), -- without dot in function name
				},
			}
		end,
		config = function(_, opts)
			require("mini.ai").setup(opts)
			NeoCraft.on_load("which-key.nvim", function()
				vim.schedule(function()
					NeoCraft.mini.ai_whichkey(opts)
				end)
			end)
		end,
	},

	{
		"folke/lazydev.nvim",
		ft = "lua",
		cmd = "LazyDev",
		opts = {
			library = {
				{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
				{ path = "NeoCraft", words = { "NeoCraft" } },
				{ path = "snacks.nvim", words = { "Snacks" } },
				{ path = "lazy.nvim", words = { "NeoCraft" } },
			},
		},
	},

	-- import coding
	{import = "neocraft.plugins.coding",}
}
