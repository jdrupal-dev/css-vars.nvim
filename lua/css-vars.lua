local luasnip = require("luasnip")

local s = luasnip.snippet
local t = luasnip.text_node
local i = luasnip.insert_node

local M = {}

local cache_file_path = "/tmp/css-vars" .. vim.loop.cwd():gsub("/", "-") .. ".txt"

local generate_snippets = function()
  if not vim.loop.fs_stat(cache_file_path) then
    return
  end

  local css_vars = {}
  for line in io.lines(cache_file_path) do
    if not css_vars[line] then
      css_vars[line] = line
    end
  end

  local snippets = {}
  for _, name in pairs(css_vars) do
    table.insert(
      snippets,
      s(name, {
        t(name),
        i(0),
      })
    )
  end

  luasnip.add_snippets("css", snippets)
  luasnip.add_snippets("less", snippets)
  luasnip.add_snippets("scss", snippets)
end

function M.setup()
  vim.fn.jobstart(
    'rg -e "(--[^:)]*):" -r \'$1\' -o --no-filename -g "*.css" -g "*.less" -g "*.scss" . > ' .. cache_file_path,
    {
      cwd = vim.loop.cwd(),
      on_exit = function()
        generate_snippets()
      end,
    }
  )
end

return M
