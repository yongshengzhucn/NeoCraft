---@class neocraft.util.pick
---@overload fun(command:string, opts?:neocraft.util.pick.Opts): fun()
local M = setmetatable({}, {
	__call = function(m, ...)
		return m.wrap(...)
	end,
})

---@class neocraft.util.pick.Opts: table<string, any>
---@field root? boolean
---@field cwd? string
---@field buf? number
---@field show_untracked? boolean

---@class LazyPicker
---@field name string
---@field open fun(command:string, opts?:neocraft.util.pick.Opts)
---@field commands table<string, string>

---@type LazyPicker?
M.picker = nil

---@param picker LazyPicker
function M.register(picker)
	-- this only happens when using :LazyExtras
	-- so allow to get the full spec
	if vim.v.vim_did_enter == 1 then
		return true
	end

	if vim.g.neocraft_picker ~= picker.name then
		return false
	end

	if M.picker and M.picker.name ~= picker.name then
		NeoCraft.warn(
			"`NeoCraft.pick`: picker already set to `"
				.. M.picker.name
				.. "`,\nignoring new picker `"
				.. picker.name
				.. "`"
		)
		return false
	end

	M.picker = picker
	return true
end

---@param command? string
---@param opts? neocraft.util.pick.Opts
function M.open(command, opts)
	if not M.picker then
		return NeoCraft.error("NeoCraft.pick: picker not set")
	end

	command = command or "auto"
	opts = opts or {}

	opts = vim.deepcopy(opts)

	if type(opts.cwd) == "boolean" then
		NeoCraft.warn("NeoCraft.pick: opts.cwd should be a string or nil")
		opts.cwd = nil
	end

	if not opts.cwd and opts.root ~= false then
		opts.cwd = NeoCraft.root({ buf = opts.buf })
	end

	local cwd = opts.cwd or vim.uv.cwd()
	if command == "auto" then
		command = "files"
		if
			vim.uv.fs_stat(cwd .. "/.git")
			and not vim.uv.fs_stat(cwd .. "/.ignore")
			and not vim.uv.fs_stat(cwd .. "/.rgignore")
		then
			command = "git_files"
			if opts.show_untracked == nil then
				opts.show_untracked = true
				opts.recurse_submodules = false
			end
		end
	end
	command = M.picker.commands[command] or command
	M.picker.open(command, opts)
end

---@param command? string
---@param opts? neocraft.util.pick.Opts
function M.wrap(command, opts)
	opts = opts or {}
	return function()
		NeoCraft.pick.open(command, vim.deepcopy(opts))
	end
end

function M.config_files()
	return M.wrap("files", { cwd = vim.fn.stdpath("config") })
end

return M
