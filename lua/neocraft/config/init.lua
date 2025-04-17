_G.NeoCraft = require("neocraft.util")

---@class NeoCraftConfig: NeocraftOptions
local M = {}

NeoCraft.config = M

---@class NeoCraftOptions
local defaults = {
	-- colorscheme can be a string like `catppuccin` or a function that will load the colorscheme
	---@type string
	colorscheme = function()
		require("catppuccin").load()
	end,

	-- load the default settings
	defaults = {
		autocmds = true, -- neocraft.config.autocmds
		keymaps = true, -- neocraft.config.keymaps
		-- neocraft.config.options can't be configured here since that's loaded before neocraft setup
		-- if you want to disable loading options, add `package.loaded["neocraft.config.options"] = true` to the top of your init.lua
	},
  -- icons used by other plugins
  -- stylua: ignore
  icons = {
    ft = {
      octo = "",
    },
    dap = {
      Stopped = { "󰁕 ", "DiagnosticWarn", "DapStoppedLine" },
      Breakpoint = " ",
      BreakpointCondition = " ",
      BreakpointRejected = { " ", "DiagnosticError" },
      LogPoint = ".>",
    },
    diagnostics = {
      Error = " ",
      Warn = " ",
      Hint = "󰠠 ",
      Info = " ",
    },
    kinds = {
      Array         = " ",
      Boolean       = "⏻ ",
      Class         = " ",
      Codeium       = "󰘦 ",
      Color         = " ",
      Control       = "󰭩 ",
      Collapsed     = " ",
      Constant      = " ",
      Constructor   = " ",
      Copilot       = " ",
      Enum          = " ",
      EnumMember    = " ",
      Event         = " ",
      Field         = "󰽑 ",
      File          = " ",
      Folder        = " ",
      Function      = "󰊕 ",
      Interface     = " ",
      Key           = " ",
      Keyword       = " ",
      Method        = " ",
      Module        = "  ",
      Namespace     = " ",
      Null          = "󰟢 ",
      Number        = "󰎠 ",
      Object        = " ",
      Operator      = " ",
      Package       = " ",
      Property      = " ",
      Reference     = " ",
      Snippet       = "󱄽 ",
      String        = " ",
      Struct        = " ",
      Supermaven    = " ",
      TabNine       = "󰏚 ",
      Text          = " ",
      TypeParameter = " ",
      Unit          = " ",
      Value         = " ",
      Variable      = "󰀫 ",
    },
  },
	---@type table<string, string[]|boolean>?
	kind_filter = {
		default = {
			"Class",
			"Constructor",
			"Enum",
			"Field",
			"Function",
			"Interface",
			"Method",
			"Module",
			"Namespace",
			"Package",
			"Property",
			"Struct",
			"Trait",
		},
		markdown = false,
		help = false,
		-- you can specify a different filter for each filetype
		lua = {
			"Class",
			"Constructor",
			"Enum",
			"Field",
			"Function",
			"Interface",
			"Method",
			"Module",
			"Namespace",
			-- "Package", -- remove package since luals uses it for control flow structures
			"Property",
			"Struct",
			"Trait",
		},
	},
}

---@param buf? number
---@return string[]?
function M.get_kind_filter(buf)
	buf = (buf == nil or buf == 0) and vim.api.nvim_get_current_buf() or buf
	local ft = vim.bo[buf].filetype
	if M.kind_filter == false then
		return
	end
	if M.kind_filter[ft] == false then
		return
	end
	if type(M.kind_filter[ft]) == "table" then
		return M.kind_filter[ft]
	end
	---@diagnostic disable-next-line: return-type-mismatch
	return type(M.kind_filter) == "table" and type(M.kind_filter.default) == "table" and M.kind_filter.default or nil
end

---@param name "autocmds" | "options" | "keymaps"
function M.load(name)
	local function _load(mod)
		if require("lazy.core.cache").find(mod)[1] then
			NeoCraft.try(function()
				require(mod)
			end, { msg = "Failed loading " .. mod })
		end
	end
	local pattern = "NeoCraft" .. name:sub(1, 1):upper() .. name:sub(2)
	-- always load neocraft, then user file
	if M.defaults[name] or name == "options" then
		_load("neocraft.config." .. name)
		vim.api.nvim_exec_autocmds("User", { pattern = pattern .. "Defaults", modeline = false })
	end
	_load("config." .. name)
	if vim.bo.filetype == "lazy" then
		-- HACK: NeoCraft may have overwritten options of the Lazy ui, so reset this here
		vim.cmd([[do VimResized]])
	end
	vim.api.nvim_exec_autocmds("User", { pattern = pattern, modeline = false })
end

---@type NeoCraftOptions
local options
local lazy_clipboard

function M.setup(opts)
	options = vim.tbl_deep_extend("force", defaults, opts or {}) or {}
	-- autocmds can be loaded lazily when not opening a file
	local lazy_autocmds = vim.fn.argc(-1) == 0
	if not lazy_autocmds then
		M.load("autocmds")
	end

	local group = vim.api.nvim_create_augroup("NeoCraft", { clear = true })
	vim.api.nvim_create_autocmd("User", {
		group = group,
		pattern = "VeryLazy",
		callback = function()
			if lazy_autocmds then
				M.load("autocmds")
			end
			M.load("keymaps")
			if lazy_clipboard ~= nil then
				vim.opt.clipboard = lazy_clipboard
			end

			NeoCraft.format.setup()
			NeoCraft.root.setup()

			vim.api.nvim_create_user_command("LazyHealth", function()
				vim.cmd([[Lazy! load all]])
				vim.cmd([[checkhealth]])
			end, { desc = "Load all plugins and run :checkhealth" })
		end,
	})

	NeoCraft.track("colorscheme")
	NeoCraft.try(function()
		if type(M.colorscheme) == "function" then
			M.colorscheme()
		else
			vim.cmd.colorscheme(M.colorscheme)
		end
	end, {
		msg = "Could not load your colorscheme",
		on_error = function(msg)
			NeoCraft.error(msg)
			vim.cmd.colorscheme("default")
		end,
	})
	NeoCraft.track()
end

M.did_init = false

function M.init()
	if M.did_init then
		return
	end
	M.did_init = true

	local plugin = require("lazy.core.config").spec.plugins.NeoCraft
	if plugin then
		vim.opt.rtp:append(plugin.dir)
	end

	NeoCraft.lazy_notify()

	-- load options here, before lazy init while sourcing plugin modules
	-- this is needed to make sure options will be correctly applied
	-- after installing missing plugins
	M.load("options")
	-- defer built-in clipboard handling: "xsel" and "pbcopy" can be slow
	lazy_clipboard = vim.opt.clipboard
	vim.opt.clipboard = ""

	NeoCraft.plugin.setup()
end

setmetatable(M, {
	__index = function(_, key)
		if options == nil then
			return vim.deepcopy(defaults)[key]
		end
		return options[key]
	end,
})

return M
