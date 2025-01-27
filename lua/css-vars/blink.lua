local Job = require("plenary.job")
local async = require("blink.cmp.lib.async")

local config
local css_variables

---Include the trigger character when accepting a completion.
---@param context blink.cmp.Context
local function transform(items, context)
	return vim.tbl_map(function(entry)
		local text = vim.api.nvim_buf_get_text(
			0,
			context.cursor[1] - 1,
			context.bounds.start_col - 3,
			context.cursor[1] - 1,
			context.cursor[2],
			{}
		)
		local newText
		if text[1]:match("%-%-.*") then
			newText = "-" .. entry.label:gmatch("-*(.*)")()
		end

		return vim.tbl_deep_extend("force", entry, {
			kind = require("blink.cmp.types").CompletionItemKind.Variable,
			textEdit = {
				newText = newText or entry.label,
				range = {
					start = { line = context.cursor[1] - 1, character = context.bounds.start_col - 2 },
					["end"] = { line = context.cursor[1] - 1, character = context.cursor[2] },
				},
			},
		})
	end, items)
end

---@type blink.cmp.Source
local M = {}

function M.new(opts)
	local self = setmetatable({}, { __index = M })
	config = vim.tbl_deep_extend("keep", opts or {}, require("css-vars.default_config"))

	if css_variables then
		return self
	end

	local args = {
		"-e",
		"[^\\w](--[^:)]*):([^;]+);",
		"-r",
		"'$1' '$2'",
		"-o",
		"--no-filename",
	}

	-- Only search in files that are listed in the "search_extensions" config.
	for _, extension in pairs(config.search_extensions) do
		table.insert(args, "-g")
		table.insert(args, "*" .. extension)
	end
	table.insert(args, vim.uv.cwd())

	Job:new({
		command = "rg",
		args = args,
		env = { PATH = vim.env.PATH },
		on_exit = function(j)
			local result = j:result()

			local items = {}
			local processed = {}
			for _, item in pairs(result) do
				local css_var, css_value = item:match("^'%-(.-)' '(.-)'")
				if not processed[css_var] then
					processed[css_var] = true
					table.insert(items, {
						filterText = css_var,
						label = "-" .. css_var,
						documentation = css_value,
					})
				end
			end
			css_variables = items
		end,
	}):start()

	return self
end

---@param context blink.cmp.Context
function M:get_completions(context, callback)
	local task = async.task.empty():map(function()
		local is_char_trigger = vim.list_contains(
			self:get_trigger_characters(),
			context.line:sub(context.bounds.start_col - 1, context.bounds.start_col - 1)
		)
		if css_variables then
			callback({
				is_incomplete_forward = true,
				is_incomplete_backward = true,
				items = is_char_trigger and transform(css_variables, context) or {},
				context = context,
			})
		end
	end)
	return function()
		task:cancel()
	end
end

function M:get_trigger_characters()
	return { "-" }
end

return M
