-- Define colors for different modes (using Catppuccin Mocha palette examples)
local mode_colors = {
  n = "#9399b2", -- Normal mode: Overlay 2
  i = "#a6e3a1", -- Insert mode: Green
  v = "#f9e2af", -- Visual mode: Yellow
  V = "#f9e2af", -- Visual Line mode: Yellow
  ["\22"] = "#f9e2af", -- Visual Block mode (^V): Yellow (\22 is the char code for Ctrl+V)
  c = "#fab387", -- Command mode: Orange
  r = "#f5c2e7", -- Replace mode: Pink
  t = "#94e2d5", -- Terminal mode: Teal
  -- Add other modes if needed (e.g., s, S, R)
  default = "#9399b2", -- Default/fallback: Lavender (original color)
}

local modified_color = "#f38ba8"

local function f(color)
  return string.format("#%06x", color)
end

local function process_path(path)
  local home_dir = vim.api.nvim_eval('expand("~")')
  -- special case for oil
  if string.find(path, home_dir) then
    path = path:gsub(home_dir, "~")
  end
  return path
end

return {

  {
    "b0o/incline.nvim",
    dependencies = {},
    config = function()
      local helpers = require("incline.helpers")
      require("incline").setup({
        window = {
          placement = {
            vertical = "top",
            horizontal = "right",
          },
          padding = 0,
          margin = { horizontal = 0 },
        },
        render = function(props)
          local buf = props.buf
          local bufname = vim.api.nvim_buf_get_name(buf)
          local filename = vim.fn.fnamemodify(bufname, ":t")
          local relative_path = vim.fn.fnamemodify(bufname, ":~:.:h")
          local buftype = vim.bo[buf].buftype
          local filetype = vim.bo[buf].filetype

          local category, separator = "extension", "/"

          if filetype == "oil" then
            category, filename, separator = "directory", relative_path, ""
          end

          if buftype == "nofile" then
            category, filename, separator = "extension", "[No Name]", "/"
          end

          if filename == "" then
            NeoCraft.warn("Not found filename for buffer: " .. buf)
            category, filename, separator = "extension", "[Special Buffer]", "/"
          end

          local ft_icon, ft_hl
          local mini_icons = require("mini.icons")
          ft_icon, ft_hl = mini_icons.get(category, filename)
          ft_icon = ft_icon or "󰈚 " -- Default file icon
          ft_hl = ft_hl or "Directory" -- Default highlight group

          local ft_color_int = vim.api.nvim_get_hl(0, { name = ft_hl }).fg
          local ft_color = ft_color_int and f(ft_color_int) or "#6c7086"

          local modified = vim.bo[props.buf].modified

          local mode_info = vim.api.nvim_get_mode()
          local current_mode = mode_info.mode

          local file_path_color = modified and modified_color or (mode_colors[current_mode] or mode_colors.default)

          local buffer_render = {}

          table.insert(buffer_render, { ft_icon, guifg = ft_color, guibg = "none" })

          table.insert(buffer_render, " ")

          local display_path = relative_path and process_path(relative_path) .. separator

          table.insert(buffer_render, { display_path, guifg = file_path_color, guibg = "none" })

          local filename_style = modified and "bold,italic" or "italic"

          filename = filetype == "oil" and "" or filename

          table.insert(buffer_render, { filename, gui = filename_style, guifg = file_path_color })

          table.insert(buffer_render, " ")

          buffer_render.guibg = "#1e1e2e"

          return buffer_render
        end,
      })
    end,
  },
}
