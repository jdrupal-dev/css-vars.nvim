local Job = require("plenary.job")

local registered = false

local M = {}
M.setup = function(cfg)
  M.__conf = vim.tbl_deep_extend("keep", cfg or {}, require("css-vars.default_config"))
  if registered then
    return
  end
  registered = true

  local args = {
    "-e",
    "[^\\w](--[^:)]*):",
    "-r",
    "'$1'",
    "-o",
    "--no-filename",
  }

  -- Only search in files that are listed in the "search_extensions" config.
  for _, extension in pairs(M.__conf.search_extensions) do
    table.insert(args, "-g")
    table.insert(args, "*" .. extension)
  end
  table.insert(args, vim.loop.cwd())

  Job:new({
    command = "rg",
    args = args,
    env = { PATH = vim.env.PATH },
    on_exit = function(j)
      local result = j:result()
      vim.schedule(function()
        local has_cmp, cmp = pcall(require, "cmp")
        if not has_cmp then
          return
        end

        local source = {}

        source.new = function()
          return setmetatable({}, { __index = source })
        end

        source.get_trigger_characters = function()
          return { "-" }
        end

        source.complete = function(_, request, callback)
          if not vim.tbl_contains(M.__conf.cmp_filetypes, request.context.filetype) then
            callback({ isIncomplete = true })
            return
          end

          local input = string.sub(request.context.cursor_before_line, request.offset - 1)
          local prefix = string.sub(request.context.cursor_before_line, 1, request.offset - 1)

          local trigger = "-"
          if vim.startswith(input, trigger) and (prefix == trigger or vim.endswith(prefix, trigger)) then
            local items = {}
            local processed = {}
            for _, item in pairs(result) do
              local css_var = (item:gsub("'%-(.*)'", "%1"))
              if processed[css_var] then
                goto continue
              end
              processed[css_var] = true
              table.insert(items, {
                filterText = css_var,
                label = "-" .. css_var,
                kind = 6,
                textEdit = {
                  newText = css_var,
                  range = {
                    start = {
                      line = request.context.cursor.row - 1,
                      character = request.context.cursor.col - 1 - #input,
                    },
                    ["end"] = {
                      line = request.context.cursor.row - 1,
                      character = request.context.cursor.col - 1,
                    },
                  },
                },
              })
              ::continue::
            end
            callback({
              items = items,
              isIncomplete = false,
            })
          else
            callback({ isIncomplete = true })
          end
        end

        cmp.register_source("css_vars", source.new())
      end)
    end,
  }):start()
end

return M
