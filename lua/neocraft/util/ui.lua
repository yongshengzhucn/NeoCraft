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

function M.show_visible_window_buffer_info()
	local windows = vim.api.nvim_tabpage_list_wins(0)
	local buffer_info = {}

	-- Define table width for consistent formatting
	local table_width = 90

	-- Return early if no windows found
	if #windows == 0 then
		vim.notify("No windows found in current tab.", vim.log.levels.WARN, { title = "Buffer Info" })
		return
	end

	-- Add empty line as first line to force separation
	table.insert(buffer_info, "")

	-- Add a centered title line after the empty line
	local title = "Visible Window Buffers"
	local padding = math.floor((table_width - #title) / 2)
	local title_line = string.rep("━", padding)
		.. " "
		.. title
		.. " "
		.. string.rep("━", table_width - padding - #title - 2)
	table.insert(buffer_info, title_line)

	-- Define table columns and format - adding window info columns
	local fmt_str = "%-3s %-6s %-20s %-20s %-15s %-12s %s"

	-- Add column headers
	table.insert(buffer_info, fmt_str:format("No.", "Win ID", "Filename", "Filetype", "Status", "Win Type", "Win Size"))
	table.insert(buffer_info, string.rep("─", table_width)) -- Separator line

	-- Iterate through window IDs
	for i, win_id in ipairs(windows) do
		-- Get the buffer ID associated with the window
		local buf_id = vim.api.nvim_win_get_buf(win_id)

		-- Get window info
		local win_type = ""
		local win_width = vim.api.nvim_win_get_width(win_id)
		local win_height = vim.api.nvim_win_get_height(win_id)
		local win_size = string.format("%dx%d", win_width, win_height)

		-- Try to determine window type
		if vim.api.nvim_win_get_config(win_id).relative ~= "" then
			win_type = "floating"
		elseif pcall(function()
			return vim.api.nvim_win_get_var(win_id, "quickfix_title")
		end) then
			win_type = "quickfix"
		elseif vim.fn.win_gettype(win_id) == "popup" then
			win_type = "popup"
		elseif vim.fn.win_gettype(win_id) == "preview" then
			win_type = "preview"
		else
			win_type = "normal"
		end

		-- Check if the buffer is valid and loaded
		if vim.api.nvim_buf_is_valid(buf_id) and vim.api.nvim_buf_is_loaded(buf_id) then
			-- Get the buffer name (file path or name)
			local buf_name = vim.api.nvim_buf_get_name(buf_id)
			local short_name = "[No Name]"

			-- Handle filename and path display
			if buf_name ~= "" then
				short_name = vim.fn.fnamemodify(buf_name, ":t") -- Just get the filename
			end

			-- Get the filetype
			local filetype = vim.bo[buf_id].filetype
			if filetype == "" then
				filetype = "[No Type]"
			end

			-- Get buffer type if no filetype
			if filetype == "[No Type]" then
				-- Try to get buffer type from buffer options or variables
				local buftype = vim.bo[buf_id].buftype
				if buftype ~= "" then
					filetype = buftype
				end
			end

			-- Get modification status
			local modified = vim.bo[buf_id].modified
			local mod_status = modified and "[Modified]" or "[Unmodified]"

			-- Format the output string and add it to the table
			local info_line = fmt_str:format(
				i,
				win_id,
				#short_name > 20 and short_name:sub(1, 17) .. "..." or short_name,
				filetype,
				mod_status,
				win_type,
				win_size,
				path
			)
			table.insert(buffer_info, info_line)
		else
			-- Handle cases where a window might not have a valid/loaded buffer
			local info_line = fmt_str:format(i, win_id, "[Invalid Buffer]", "-", "-", win_type, win_size)
			table.insert(buffer_info, info_line)
		end
	end

	-- Add ending separator
	table.insert(buffer_info, string.rep("━", table_width))

	-- Add information about current active window
	local current_win = vim.api.nvim_get_current_win()
	table.insert(buffer_info, string.format("Active Window: %d", current_win))

	-- Display the collected information using vim.notify
	vim.notify(table.concat(buffer_info, "\n"), vim.log.levels.INFO, {
		title = "Buffer Info", -- Keep the title simple to avoid confusion
		timeout = 10000, -- Longer display time (10 seconds)
		icon = "", -- Buffer icon (requires Nerd Font support)
	})
end

return M
