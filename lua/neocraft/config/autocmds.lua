-- This file is automatically loaded by neocraft.config.init.

local function augroup(name)
	return vim.api.nvim_create_augroup("neocraft_" .. name, { clear = true })
end

-- Check if we need to reload the file when it changed
vim.api.nvim_create_autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
	group = augroup("checktime"),
	callback = function()
		if vim.o.buftype ~= "nofile" then
			vim.cmd("checktime")
		end
	end,
})

-- Highlight on yank
vim.api.nvim_create_autocmd("TextYankPost", {
	group = augroup("highlight_yank"),
	callback = function()
		(vim.hl or vim.highlight).on_yank()
	end,
})

-- resize splits if window got resized
vim.api.nvim_create_autocmd({ "VimResized" }, {
	group = augroup("resize_splits"),
	callback = function()
		local current_tab = vim.fn.tabpagenr()
		vim.cmd("tabdo wincmd =")
		vim.cmd("tabnext " .. current_tab)
	end,
})

-- go to last loc when opening a buffer
vim.api.nvim_create_autocmd("BufReadPost", {
	group = augroup("last_loc"),
	callback = function(event)
		local exclude = { "gitcommit" }
		local buf = event.buf
		if vim.tbl_contains(exclude, vim.bo[buf].filetype) or vim.b[buf].neocraft_last_loc then
			return
		end
		vim.b[buf].neocraft_last_loc = true
		local mark = vim.api.nvim_buf_get_mark(buf, '"')
		local lcount = vim.api.nvim_buf_line_count(buf)
		if mark[1] > 0 and mark[1] <= lcount then
			pcall(vim.api.nvim_win_set_cursor, 0, mark)
		end
	end,
})

-- close some filetypes with <q>
vim.api.nvim_create_autocmd("FileType", {
	group = augroup("close_with_q"),
	pattern = {
		"PlenaryTestPopup",
		"checkhealth",
		"dbout",
		"gitsigns-blame",
		"grug-far",
		"help",
		"lspinfo",
		"neotest-output",
		"neotest-output-panel",
		"neotest-summary",
		"notify",
		"qf",
		"spectre_panel",
		"startuptime",
		"tsplayground",
		"fzf",
	},
	callback = function(event)
		vim.bo[event.buf].buflisted = false
		vim.schedule(function()
			vim.keymap.set("n", "q", function()
				vim.cmd("close")
				pcall(vim.api.nvim_buf_delete, event.buf, { force = true })
			end, {
				buffer = event.buf,
				silent = true,
				desc = "Quit buffer",
			})
		end)
	end,
})

-- make it easier to close man-files when opened inline
vim.api.nvim_create_autocmd("FileType", {
	group = augroup("man_unlisted"),
	pattern = { "man" },
	callback = function(event)
		vim.bo[event.buf].buflisted = false
	end,
})

-- wrap and check for spell in text filetypes
vim.api.nvim_create_autocmd("FileType", {
	group = augroup("wrap_spell"),
	pattern = { "text", "plaintex", "typst", "gitcommit", "markdown" },
	callback = function()
		vim.opt_local.wrap = true
		vim.opt_local.spell = true
	end,
})

-- Fix conceallevel for json files
vim.api.nvim_create_autocmd({ "FileType" }, {
	group = augroup("json_conceal"),
	pattern = { "json", "jsonc", "json5" },
	callback = function()
		vim.opt_local.conceallevel = 0
	end,
})

-- Auto create dir when saving a file, in case some intermediate directory does not exist
vim.api.nvim_create_autocmd({ "BufWritePre" }, {
	group = augroup("auto_create_dir"),
	callback = function(event)
		if event.match:match("^%w%w+:[\\/][\\/]") then
			return
		end
		local file = vim.uv.fs_realpath(event.match) or event.match
		vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
	end,
})

-- CursorMoved url
vim.api.nvim_create_autocmd({ "CursorMoved" }, {
	group = augroup("highlight_Cursor_URL"),
	callback = function()
		NeoCraft.browse.hl_cursor()
	end,
})

local prefix = "Avante" --

local function update_laststatus_for_avante()
	local avante_window_found = false
	for _, winid in ipairs(vim.api.nvim_list_wins()) do
		if vim.api.nvim_win_is_valid(winid) then
			local bufnr = vim.api.nvim_win_get_buf(winid)
			if vim.api.nvim_buf_is_valid(bufnr) and vim.api.nvim_buf_is_loaded(bufnr) then
				local ft = vim.api.nvim_buf_get_option(bufnr, "filetype")
				if ft and string.find(ft, prefix, 1, true) == 1 then
					avante_window_found = true
					break
				end
			end
		end
	end
	if avante_window_found then
		if vim.opt.laststatus:get() ~= 3 then
			vim.opt.laststatus = 3
		end
	else
		if vim.opt.laststatus:get() ~= 1 then
			vim.opt.laststatus = 1
		end
	end
end

vim.api.nvim_create_autocmd("FileType", {
	group = augroup("AvanteLastStatus"),
	pattern = "Avante*",
	callback = update_laststatus_for_avante,
	desc = "Update laststatus on Avante* FileType change",
})

vim.api.nvim_create_autocmd({ "WinEnter", "WinClosed", "BufWinEnter" }, {
	group = augroup("AvanteLastStatus"),
	pattern = "*",
	callback = update_laststatus_for_avante,
	desc = "Update laststatus on window/buffer changes",
})
