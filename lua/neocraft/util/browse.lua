---@class neocraft.util.browse
local M = {}

local url_pattern = "(https?://[%w-_%.%?%.:/%+=&%%@]+)"

local extract_url = function(line)
  local url = string.match(line, url_pattern)
  if url then
    return url
  end
end

local delete_url_effect = function(group_name)
  for _, match in ipairs(vim.fn.getmatches()) do
    if match.group == group_name then
      vim.fn.matchdelete(match.id)
    end
  end
end

local set_url_effect = function()
  delete_url_effect("HighlightAllUrl")
  vim.fn.matchadd("HighlightAllUrl", url_pattern, 15)
end

local find_first_url_mapping_pattern = function(text, pattern, start_pos)
  start_pos = start_pos or 1
  local start_found, end_found, url_found = nil, nil, nil
  local start_pos_result, end_pos_result, url = text:find(pattern, start_pos)
  if url and start_pos_result < string.len(text) then
    start_found, end_found, url_found = start_pos_result, end_pos_result, url
  end
  return start_found, end_found, url_found
end

M.hl_cursor = function()
  delete_url_effect("HighlightCursorUrl")
  local cursor_pos = vim.api.nvim_win_get_cursor(0)
  local cursor_row = cursor_pos[1]
  local cursor_col = cursor_pos[2]
  local line = vim.api.nvim_get_current_line()
  local start_pos, end_pos, url = find_first_url_mapping_pattern(line, url_pattern)
  if url then
    vim.fn.matchaddpos("HighlightCursorUrl", { { cursor_row, start_pos, end_pos - start_pos + 1 } }, 20)
  end
end

-- local function get_url_from_lines(cline, bline)
--   local url = extract_url(cline)
--   local cur_url = url
--   if url then
--     local escurl = url:gsub("[-/\\.]", "%%%1")
--     if string.match(cline, escurl .. "$") then
--       cline = cline .. bline
--       url = extract_url(cline)
--     end
--   end
--   return url ~= cur_url, url
-- end

M.open = function()
  local current_line = vim.api.nvim_get_current_line()
  local above_line = vim.api.nvim_buf_get_lines(
    0,
    vim.api.nvim_win_get_cursor(0)[1] - 2,
    vim.api.nvim_win_get_cursor(0)[1] - 1,
    false
  )[1] or ""
  local below_line = vim.api.nvim_buf_get_lines(
    0,
    vim.api.nvim_win_get_cursor(0)[1],
    vim.api.nvim_win_get_cursor(0)[1] + 1,
    false
  )[1] or ""

  local url = extract_url(current_line)

  if url then
    vim.notify("Open " .. url, vim.log.levels.INFO, { title = "neocraft-browse" })
    os.execute("open " .. url)
  else
    vim.notify("Not detected any url.", vim.log.levels.WARN, { title = "neocraft-browse" })
  end
end

return M
