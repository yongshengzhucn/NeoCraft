---@module 'snacks'

---@type LazyPicker
local picker = {
  name = "snacks",
  commands = {
    files = "files",
    live_grep = "grep",
    oldfiles = "recent",
  },

  ---@param source string
  ---@param opts? snacks.picker.Config
  open = function(source, opts)
    return Snacks.picker.pick(source, opts)
  end,
}
---TODO: wait for update to fix some known bugs
if not NeoCraft.pick.register(picker) then
  return {}
end

local ivy_layout_sources = {
  "grep",
  "grep_buffers",
  "todo_comments",
  "lsp_config",
  "lsp_definitions",
  "lsp_references",
  "lsp_implementations",
  "lsp_type_definitions",
  "lsp_symbols",
  "lsp_workspace_symbols",
  "notifications",
  "git_stash",
  "git_status",
  "git_diff",
  "live_grep",
  "lines",
  "grep_buffers",
  "grep_word",
  "lazy",
  "registers",
  "autocmds",
  "commands",
  "undo",
  "qflist",
  "resume",
  "marks",
  "man",
  "loclist",
  "keymaps",
  "jumps",
  "highlights",
  "help",
  "diagnostics_buffer",
  "diagnostics",
}
local hide_preview_sources = { "files", "buffers", "oldfiles", "config_files", "git_files", "recent", "projects" }

return {
  desc = "Fast and modern file picker",
  recommended = true,
  {
    "folke/snacks.nvim",
    opts = {
      picker = {
        prompt = "  ",
        layout = {
          preset = "neocraft",
        },
        -- layout = function(source)
        -- 	vim.notify("source: " .. source)
        -- 	local layout_config = {}
        -- 	layout_config.preset = "default"
        -- 	for _, ils in ipairs(ivy_layout_sources) do
        -- 		if string.find(source, ils) then
        -- 			layout_config.preset = "ivy"
        -- 			break
        -- 		end
        -- 	end
        -- 	for _, hps in ipairs(hide_preview_sources) do
        -- 		if string.find(source, hps) then
        -- 			layout_config.hidden = { "preview" }
        -- 		end
        -- 	end
        -- 	return layout_config
        -- end,

        sources = {
          files = {
            layout = {
              preset = "neocraft",
            },
          },
        },
        layouts = {
          neocraft = {
            layout = {
              box = "horizontal",
              width = 0.8,
              min_width = 120,
              height = 0.8,
              {
                box = "vertical",
                border = "solid",
                title = " {title} {live} {flags} ",
                { win = "input", height = 1, border = "solid" },
                { win = "list", border = "hpad" },
              },
              { win = "preview", title = "{preview}", border = "solid", width = 0.5 },
            },
          },
        },

        win = {
          input = {
            keys = {
              ["<Tab>"] = {
                "focus_preview",
                mode = { "n", "i" },
              },
            },
          },
        },
        actions = {
          ---@param p snacks.Picker
          toggle_cwd = function(p)
            local root = NeoCraft.root({ buf = p.input.filter.current_buf, normalize = true })
            local cwd = vim.fs.normalize((vim.uv or vim.loop).cwd() or ".")
            local current = p:cwd()
            p:set_cwd(current == root and cwd or root)
            p:find()
          end,
        },
      },
    },
    -- stylua: ignore
    keys = {
      { "<leader>,", function() Snacks.picker.buffers() end, desc = "Buffers" },
      { "<leader>/", NeoCraft.pick("grep",{ hidden = true }), desc = "Grep (Root Dir)" },
      { "<leader>:", function() Snacks.picker.command_history() end, desc = "Command History" },
      { "<leader>j", function() Snacks.picker.notifications() end, desc = "Notification History" },
      { "<space>h", function() Snacks.picker.help() end, desc = "Help Pages" },
      { "<space>/", NeoCraft.pick("files"), desc = "Find Files (Root Dir)" },
      { "<space>r", function() Snacks.picker.smart() end, desc = "Recent (smart)", },
      -- find
      { "<leader>fb", function() Snacks.picker.buffers() end, desc = "Buffers" },
      -- { "<leader>fB", function() Snacks.picker.buffers({ hidden = true, nofile = true }) end, desc = "Buffers (all)" },
      { "<leader>fc", NeoCraft.pick.config_files(), desc = "Find Config File" },
      { "<leader>ff", NeoCraft.pick("files"), desc = "Find Files (Root Dir)" },
      -- { "<leader>fF", NeoCraft.pick("files", { root = false }), desc = "Find Files (cwd)" },
      { "<leader>fg", function() Snacks.picker.git_files() end, desc = "Find Files (git-files)" },
      { "<leader>fr", NeoCraft.pick("oldfiles"), desc = "Recent" },
      -- { "<leader>fR", function() Snacks.picker.recent({ filter = { cwd = true }}) end, desc = "Recent (cwd)" },
      { "<leader>fp", function() Snacks.picker.projects() end, desc = "Projects" },
      -- git
      { "<leader>gd", function() Snacks.picker.git_diff() end, desc = "Git Diff (hunks)" },
      { "<leader>gs", function() Snacks.picker.git_status() end, desc = "Git Status" },
      { "<leader>gS", function() Snacks.picker.git_stash() end, desc = "Git Stash" },
      -- Grep
      { "<leader>sb", function() Snacks.picker.lines() end, desc = "Buffer Lines" },
      -- { "<leader>sB", function() Snacks.picker.grep_buffers() end, desc = "Grep Open Buffers" },
      -- { "<leader>sg", NeoCraft.pick("live_grep"), desc = "Grep (Root Dir)" },
      -- { "<leader>sG", NeoCraft.pick("live_grep", { root = false }), desc = "Grep (cwd)" },
      { "<leader>sp", function() Snacks.picker.lazy() end, desc = "Search for Plugin Spec" },
      { "<leader>sw", NeoCraft.pick("grep_word"), desc = "Visual selection or word (Root Dir)", mode = { "n", "x" } },
      -- { "<leader>sW", NeoCraft.pick("grep_word", { root = false }), desc = "Visual selection or word (cwd)", mode = { "n", "x" } },
      -- search
      -- { "<leader>sr", function() Snacks.picker.registers() end, desc = "Registers" },
      { "<leader>s/", function() Snacks.picker.search_history() end, desc = "Search History" },
      { "<leader>sa", function() Snacks.picker.autocmds() end, desc = "Autocmds" },
      { "<leader>sc", function() Snacks.picker.command_history() end, desc = "Command History" },
      { "<leader>sC", function() Snacks.picker.commands() end, desc = "Commands" },
      { "<leader>sd", function() Snacks.picker.diagnostics() end, desc = "Diagnostics" },
      { "<leader>sD", function() Snacks.picker.diagnostics_buffer() end, desc = "Buffer Diagnostics" },
      { "<leader>sh", function() Snacks.picker.help() end, desc = "Help Pages" },
      { "<leader>sH", function() Snacks.picker.highlights() end, desc = "Highlights" },
      { "<leader>si", function() Snacks.picker.icons() end, desc = "Icons" },
      { "<leader>sj", function() Snacks.picker.jumps() end, desc = "Jumps" },
      { "<leader>sk", function() Snacks.picker.keymaps() end, desc = "Keymaps" },
      { "<leader>sl", function() Snacks.picker.loclist() end, desc = "Location List" },
      { "<leader>sM", function() Snacks.picker.man() end, desc = "Man Pages" },
      { "<leader>sm", function() Snacks.picker.marks() end, desc = "Marks" },
      { "<leader>sR", function() Snacks.picker.resume() end, desc = "Resume" },
      { "<leader>sq", function() Snacks.picker.qflist() end, desc = "Quickfix List" },
      { "<leader>su", function() Snacks.picker.undo() end, desc = "Undotree" },
    },
  },
  {
    "folke/snacks.nvim",
    opts = function(_, opts)
      if NeoCraft.has("trouble.nvim") then
        return vim.tbl_deep_extend("force", opts or {}, {
          picker = {
            actions = {
              trouble_open = function(...)
                return require("trouble.sources.snacks").actions.trouble_open.action(...)
              end,
            },
            win = {
              input = {
                keys = {
                  ["<a-t>"] = {
                    "trouble_open",
                    mode = { "n", "i" },
                  },
                },
              },
            },
          },
        })
      end
    end,
  },
  {
    "neovim/nvim-lspconfig",
    opts = function()
      local Keys = require("neocraft.plugins.lsp.keymaps").get()
      -- stylua: ignore
      vim.list_extend(Keys, {
        { "gd", function() Snacks.picker.lsp_definitions() end, desc = "Goto Definition", has = "definition" },
        { "gr", function() Snacks.picker.lsp_references() end, nowait = true, desc = "References" },
        { "gI", function() Snacks.picker.lsp_implementations() end, desc = "Goto Implementation" },
        { "gy", function() Snacks.picker.lsp_type_definitions() end, desc = "Goto T[y]pe Definition" },
        { "<leader>ss", function() Snacks.picker.lsp_symbols({ filter = NeoCraft.config.kind_filter }) end, desc = "LSP Symbols", has = "documentSymbol" },
        { "<leader>sS", function() Snacks.picker.lsp_workspace_symbols({ filter = NeoCraft.config.kind_filter }) end, desc = "LSP Workspace Symbols", has = "workspace/symbols" },
      })
    end,
  },
  {
    "folke/todo-comments.nvim",
    optional = true,
    -- stylua: ignore
    keys = {
      { "<leader>st", function() Snacks.picker.todo_comments() end, desc = "Todo" },
      { "<leader>sT", function () Snacks.picker.todo_comments({ keywords = { "TODO", "FIX", "FIXME" } }) end, desc = "Todo/Fix/Fixme" },
    },
  },
  {
    "folke/flash.nvim",
    optional = true,
    specs = {
      {
        "folke/snacks.nvim",
        opts = {
          picker = {
            win = {
              input = {
                keys = {
                  ["<a-s>"] = { "flash", mode = { "n", "i" } },
                  ["s"] = { "flash" },
                },
              },
            },
            actions = {
              flash = function(picker)
                require("flash").jump({
                  pattern = "^",
                  label = { after = { 0, 0 } },
                  search = {
                    mode = "search",
                    exclude = {
                      function(win)
                        return vim.bo[vim.api.nvim_win_get_buf(win)].filetype ~= "snacks_picker_list"
                      end,
                    },
                  },
                  action = function(match)
                    local idx = picker.list:row2idx(match.pos[1])
                    picker.list:_move(idx, true, true)
                  end,
                })
              end,
            },
          },
        },
      },
    },
  },
}
