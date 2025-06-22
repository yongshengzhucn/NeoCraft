return {
  "github/copilot.vim",
  event = "InsertEnter",
  config = function()
    -- 禁用默认的 Tab 映射
    vim.g.copilot_no_tab_map = true
    -- 自定义接受建议的快捷键
    vim.keymap.set("i", "<M-l>", 'copilot#Accept("\\<CR>")', {
      expr = true,
      replace_keycodes = false,
    })
    vim.g.copilot_filetypes = {
      ["*"] = false,
      ["markdown"] = true,
      ["text"] = true,
      ["html"] = true,
      ["javascript"] = true,
      ["typescript"] = true,
      ["python"] = true,
      ["lua"] = true,
    }
    -- 项目根目录检测函数
    local function find_project_root()
      local markers = { ".git", "package.json", "Cargo.toml", "pyproject.toml" }
      local path = vim.fn.expand("%:p:h")

      for _, marker in ipairs(markers) do
        local found = vim.fn.finddir(marker, path .. ";")
        if found ~= "" then
          return vim.fn.fnamemodify(found, ":h")
        end

        local found_file = vim.fn.findfile(marker, path .. ";")
        if found_file ~= "" then
          return vim.fn.fnamemodify(found_file, ":h")
        end
      end

      return vim.fn.getcwd()
    end
    -- 自动设置工作区文件夹
    vim.api.nvim_create_autocmd("BufEnter", {
      callback = function()
        local project_root = find_project_root()
        vim.b.workspace_folder = project_root
      end,
    })
  end,
}
