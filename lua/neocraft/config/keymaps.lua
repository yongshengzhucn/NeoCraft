-- This file is automatically loaded by neocraft.config.init

local map = NeoCraft.safe_keymap_set

-- stylua: ignore start

-- better up/down
map({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { desc = "Down", expr = true, silent = true })
map({ "n", "x" }, "<Down>", "v:count == 0 ? 'gj' : 'j'", { desc = "Down", expr = true, silent = true })
map({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { desc = "Up", expr = true, silent = true })
map({ "n", "x" }, "<Up>", "v:count == 0 ? 'gk' : 'k'", { desc = "Up", expr = true, silent = true })

-- navigate between wezterm and neovim panes
map({ "n", "i", "v" }, "<C-h>", "<cmd>lua NeoCraft.wezterm.move('h')<cr>", { desc = "Move to Left Pane" })
map({ "n", "i", "v" }, "<C-j>", "<cmd>lua NeoCraft.wezterm.move('j')<cr>", { desc = "Move to Lower Pane" })
map({ "n", "i", "v" }, "<C-k>", "<cmd>lua NeoCraft.wezterm.move('k')<cr>", { desc = "Move to Upper Pane" })
map({ "n", "i", "v" }, "<C-l>", "<cmd>lua NeoCraft.wezterm.move('l')<cr>", { desc = "Move to Right Pane" })

-- Move Lines
map("n", "<A-j>", "<cmd>execute 'move .+' . v:count1<cr>==", { desc = "Move Down" })
map("n", "<A-k>", "<cmd>execute 'move .-' . (v:count1 + 1)<cr>==", { desc = "Move Up" })
map("i", "<A-j>", "<esc><cmd>m .+1<cr>==gi", { desc = "Move Down" })
map("i", "<A-k>", "<esc><cmd>m .-2<cr>==gi", { desc = "Move Up" })
map("v", "<A-j>", ":<C-u>execute \"'<,'>move '>+\" . v:count1<cr>gv=gv", { desc = "Move Down" })
map("v", "<A-k>", ":<C-u>execute \"'<,'>move '<-\" . (v:count1 + 1)<cr>gv=gv", { desc = "Move Up" })

-- buffers
map("n", "<S-h>", "<cmd>bprevious<cr>", { desc = "Prev Buffer" })
map("n", "<S-l>", "<cmd>bnext<cr>", { desc = "Next Buffer" })
map("n", "<Space>,", "<cmd>e #<cr>", { desc = "Switch to Other Buffer" })
map("n", "bd", function() Snacks.bufdelete() end, { desc = "Delete buffer" }) 
map("n", "bo", function() Snacks.bufdelete.other() end, { desc = "Delete Other Buffers" })

-- Clear search and stop snippet on escape
map({ "i", "n", "s" }, "<esc>", function() vim.cmd("noh") NeoCraft.cmp.actions.snippet_stop() return "<esc>" end, { expr = true, desc = "Escape and Clear hlsearch" })

-- https://github.com/mhinz/vim-galore#saner-behavior-of-n-and-n
map("n", "n", "'Nn'[v:searchforward].'zv'", { expr = true, desc = "Next Search Result" })
map("x", "n", "'Nn'[v:searchforward]", { expr = true, desc = "Next Search Result" })
map("o", "n", "'Nn'[v:searchforward]", { expr = true, desc = "Next Search Result" })
map("n", "N", "'nN'[v:searchforward].'zv'", { expr = true, desc = "Prev Search Result" })
map("x", "N", "'nN'[v:searchforward]", { expr = true, desc = "Prev Search Result" })
map("o", "N", "'nN'[v:searchforward]", { expr = true, desc = "Prev Search Result" })

-- Clear search, diff update and redraw
-- taken from runtime/lua/_editor.lua
map( "n", "<leader>r", "<Cmd>nohlsearch<Bar>diffupdate<Bar>normal! <C-L><CR>", { desc = "Redraw/Clear hlsearch/Diff Update" })

-- better indenting
map("v", "<", "<gv")
map("v", ">", ">gv")

-- quickfix and diagnostics
map("n", "<leader>td", function() vim.diagnostic.open_float(nil, { focusable = false, border = "rounded", }) end, { desc = "Line Diagnostics" })

-- windows
map("n", "wd", "<C-W>c", { desc = "Delete Window", remap = true })
map("n", "<leader>-", "<C-W>s", { desc = "Split Window Below", remap = true })
map("n", "<leader>|", "<C-W>v", { desc = "Split Window Right", remap = true })

-- Move to window using the <ctrl> hjkl keys
-- map("n", "<C-h>", "<C-w>h", { desc = "Go to Left Window", remap = true })
-- map("n", "<C-j>", "<C-w>j", { desc = "Go to Lower Window", remap = true })
-- map("n", "<C-k>", "<C-w>k", { desc = "Go to Upper Window", remap = true })
-- map("n", "<C-l>", "<C-w>l", { desc = "Go to Right Window", remap = true })

-- Resize window using <ctrl> arrow keys
map("n", "<C-Up>", '<cmd>lua NeoCraft.ui.resize("horizontal", 2)<CR>', { desc = "Increase Window Height" })
map("n", "<C-Down>", '<cmd>lua NeoCraft.ui.resize("horizontal", -2)<CR>', { desc = "Decrease Window Height" })
map("n", "<C-Left>", '<cmd>lua NeoCraft.ui.resize("vertical", -2)<CR>', { desc = "Decrease Window Width" })
map("n", "<C-Right>", '<cmd>lua NeoCraft.ui.resize("vertical", 2)<CR>', { desc = "Increase Window Width" })

-- tabs
map("n", "<leader><tab>", "<cmd>tabnew<cr>", { desc = "New Tab" })
map("n", "td", "<cmd>tabclose<cr>", { desc = "Close Tab" })
-- map("n", "<tab>", "<cmd>tabnext<cr>", { desc = "Next Tab" })
-- map("n", "<s-tab>", "<cmd>tabprevious<cr>", { desc = "Previous Tab" })

-- lazygit

if vim.fn.executable("lazygit") == 1 then
  map("n", "<leader>gg", function() Snacks.lazygit({ cwd = NeoCraft.root.git() }) end, { desc = "Lazygit (Root Dir)" })
  map("n", "<leader>gG", function() Snacks.lazygit() end, { desc = "Lazygit (cwd)" })
  map("n", "<leader>gf", function() Snacks.picker.git_log_file() end, { desc = "Git Current File History" })
  map("n", "<leader>gl", function() Snacks.picker.git_log({ cwd = NeoCraft.root.git() }) end, { desc = "Git Log" })
  map("n", "<leader>gL", function() Snacks.picker.git_log() end, { desc = "Git Log (cwd)" })
end

map("n", "<leader>gb", function() Snacks.picker.git_log_line() end, { desc = "Git Blame Line" })
map({ "n", "x" }, "<leader>gB", function() Snacks.gitbrowse() end, { desc = "Git Browse (open)" })
map({ "n", "x" }, "<leader>gY", function() Snacks.gitbrowse({ open = function(url) vim.fn.setreg("+", url) end, notify = false, }) end, { desc = "Git Browse (copy)" })

-- lazy
map("n", "<leader>l", "<cmd>Lazy<cr>", { desc = "Lazy" })

-- oil
map("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })

-- quit
map("n", "<leader>q", "<cmd>qa<cr>", { desc = "Quit All" })

-- Save
map("n", "<space>w", "<cmd>update<cr>", { desc = "Save Current buffer" })

-- Lua cmdline
map("n", "<space>l", function()
  vim.fn.feedkeys(vim.api.nvim_replace_termcodes(":lua ", true, false, true))
end, { desc = "Lua cmdline" })

-- manual formatting
map({ "n", "v" }, "<space>x", "<cmd>LazyFormat<cr>", { desc = "Format selection or buffer" })

-- browse url
map("n", "<space>o", function() NeoCraft.browse.open() end, { desc = "Open url under cursor" })

-- toggle
Snacks.toggle.profiler():map("<leader>up")
map("n", "<leader>ux", function() NeoCraft.ui.display_window_buffer_info() end, { desc = "Display window buffer info" })
-- toggle lsp inlay hints
if vim.lsp.inlay_hint then Snacks.toggle.inlay_hints():map("<leader>uh") end
NeoCraft.format.snacks_toggle(true):map("<leader>uf")



-- better y
map("n", "<space>y", "^y$", { desc = "Yank to end of line" })

-- commenting
map("n", "gcu", "o<esc>Vcx<esc><cmd>normal gcc<cr>fxa<bs>", { desc = "Add Comment Below" })
map("n", "gcd", "O<esc>Vcx<esc><cmd>normal gcc<cr>fxa<bs>", { desc = "Add Comment Above" })


-- floating terminal
map("n", "<space>t", function() Snacks.terminal() end, { desc = "Terminal (cwd)" })
map("n", "<c-/>",      function() Snacks.terminal(nil, { cwd = NeoCraft.root.bufdir() }) end, { desc = "Terminal (Current Buffer Dir)" })

-- Terminal Mappings
map("t", "<C-/>", "<cmd>close<cr>", { desc = "Hide Terminal" })

-- copy current file name
map("n", "<space>n", function ()
  local filename = vim.fn.expand('%:t')
  vim.fn.system('echo -n ' .. filename .. ' | pbcopy')
end, { desc = "Copy Current File Name" })
