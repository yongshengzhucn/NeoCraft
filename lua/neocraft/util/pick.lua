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
M.picker = {
  name = "telescope",
  commands = {
    files = "find_files",
  },
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
