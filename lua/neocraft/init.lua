vim.uv = vim.uv or vim.loop

local M = {}

---@param opts? NeoCraftConfig
function M.setup(opts)
  require("neocraft.config").setup(opts)
end

return M
