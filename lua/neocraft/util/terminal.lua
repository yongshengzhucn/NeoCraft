local M = setmetatable({}, {
  __call = function(m, ...)
    return m.open(...)
  end,
})

local terminals = {}

function M.open(cmd, opts)
  opts = vim.tbl_deep_extend("force", {
    ft = "lazyterm",
    size = { width = 0.9, height = 0.9 },
    backdrop = NeoCraft.has("edgy.nvim") and not cmd and 100 or nil,
  }, opts or {}, { persistent = true }) --[[@as LazyTermOpts]]

  local termkey = vim.inspect({ cmd = cmd or "shell", cwd = opts.cwd, env = opts.env, count = vim.v.count1 })

  if terminals[termkey] and terminals[termkey]:buf_valid() then
    terminals[termkey]:toggle()
  else
    terminals[termkey] = require("lazy.util").float_term(cmd, opts)
    local buf = terminals[termkey].buf
    vim.b[buf].lazyterm_cmd = cmd
    if opts.esc_esc == false then
      vim.keymap.set("t", "<esc>", "<esc>", { buffer = buf, nowait = true })
    end
    if opts.ctrl_hjkl == false then
      vim.keymap.set("t", "<c-h>", "<c-h>", { buffer = buf, nowait = true })
      vim.keymap.set("t", "<c-j>", "<c-j>", { buffer = buf, nowait = true })
      vim.keymap.set("t", "<c-k>", "<c-k>", { buffer = buf, nowait = true })
      vim.keymap.set("t", "<c-l>", "<c-l>", { buffer = buf, nowait = true })
    end

    vim.api.nvim_create_autocmd("BufEnter", {
      buffer = buf,
      callback = function()
        vim.cmd.startinsert()
      end,
    })

    vim.cmd("noh")
  end

  return terminals[termkey]
end

M.open_with_venv = function()
  local venv_path = vim.fn.getenv("VIRTUAL_ENV") == vim.NIL and vim.fn.getenv("CONDA_PREFIX")
    or vim.fn.getenv("VIRTUAL_ENV")
  if venv_path == vim.NIL or venv_path == "" then
    vim.notify("VIRTUAL_ENV or CONDA_PREFIX not set.", vim.log.levels.WARN, { title = "neocraft-terminal" })
    return
  end
  if string.match(venv_path, "anaconda") then
    local venv_name = venv_path:match(".*/(.*)")
    vim.notify("Opening terminal with conda env: " .. venv_name, vim.log.levels.INFO, { title = "neocraft-terminal" })
    if Neocraft.has("toggleterm.nvim") then
      require("toggleterm").exec("conda activate " .. venv_name)
    else
      M.open("conda activate " .. venv_name)
    end
    return
  end
  vim.notify("Unsupported venv: " .. venv_path, vim.log.levels.WARN, { title = "neocraft-terminal" })
end

return M
