---@class neocraft.util.ui
local M = {}

-- optimized treesitter foldexpr for Neovim >= 0.10.0
function M.foldexpr()
  local buf = vim.api.nvim_get_current_buf()
  if vim.b[buf].ts_folds == nil then
    -- as long as we don't have a filetype, don't bother
    -- checking if treesitter is available (it won't)
    if vim.bo[buf].filetype == "" then
      return "0"
    end
    if vim.bo[buf].filetype:find("dashboard") then
      vim.b[buf].ts_folds = false
    else
      vim.b[buf].ts_folds = pcall(vim.treesitter.get_parser, buf)
    end
  end
  return vim.b[buf].ts_folds and vim.treesitter.foldexpr() or "0"
end

M.resize = function(split, delta)
  local win = vim.api.nvim_get_current_win()
  local width = vim.api.nvim_win_get_width(win)
  local height = vim.api.nvim_win_get_height(win)

  if split == "vertical" then
    local is_left = true
    for _, w in ipairs(vim.api.nvim_list_wins()) do
      if w == win then
        break
      end
      if vim.api.nvim_win_get_width(w) > 0 then
        is_left = not is_left
      end
    end
    if is_left then
      vim.api.nvim_command("vertical resize " .. tostring(width + delta))
    else
      vim.api.nvim_command("vertical resize " .. tostring(width - delta))
    end
  elseif split == "horizontal" then
    local is_top = true
    for _, w in ipairs(vim.api.nvim_list_wins()) do
      if w == win then
        break
      end
      if vim.api.nvim_win_get_height(w) > 0 then
        is_top = not is_top
      end
    end
    if is_top then
      vim.api.nvim_command("resize " .. tostring(height + delta))
    else
      vim.api.nvim_command("resize " .. tostring(height - delta))
    end
  end
end

return M
