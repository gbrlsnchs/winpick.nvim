local internal = require("winpick.internal")

local api = vim.api

local ESC_CODE = 27

local defaults = internal.defaults

local M = {}

--- Prompts for a window to be selected. A callback is used for handling the action. The default
--- action is to focus the selected window. The argument passed to the callback is a window ID if a
--- window is selected or nil if it the selection is aborted.
--- @param opts table: Optional options that may override global options.
--- @return number: Window ID of the selected window.
function M.select(opts)
	opts = vim.tbl_deep_extend("force", defaults, opts or {})

	local wins = api.nvim_tabpage_list_wins(0)

	-- Filter out some buffers according to configuration.
	local eligible_wins = vim.tbl_filter(function(win)
		local win_excludes = opts.win_excludes or {}

		for opt_name, value in pairs(win_excludes) do
			local option = api.nvim_win_get_option(win, opt_name)
			local exclude = (vim.tbl_islist(value) and value) or { value }

			if vim.tbl_contains(exclude, option) then
				return false
			end
		end


		local buf_excludes = opts.buf_excludes or {}
		local bufnr = api.nvim_win_get_buf(win)

		for opt_name, value in pairs(buf_excludes) do
			local option = api.nvim_buf_get_option(bufnr, opt_name)
			local exclude = (vim.tbl_islist(value) and value) or { value }

			if vim.tbl_contains(exclude, option) then
				return false
			end
		end

		return true
	end, wins)

	if #eligible_wins == 0 then
		eligible_wins = wins
	end

	if #eligible_wins == 1 then
		return eligible_wins[1]
	end

	local targets = {}

	for idx, win in ipairs(eligible_wins) do
		targets[internal.format_index(idx)] = win
	end

	local cues = internal.show_cues(targets, opts.border)

	vim.cmd("mode") -- clear cmdline once
	print(opts.prompt or defaults.prompt)

	local ok, choice = pcall(vim.fn.getchar) -- Ctrl-C returns an error

	vim.cmd("mode") -- clear cmdline again to remove pick-up message
	internal.hide_cues(cues)

	local is_ctrl_c = not ok
	local is_esc = choice == ESC_CODE

	if is_ctrl_c or is_esc then
		return nil
	end

	choice = string.char(choice):upper()

	return targets[choice]
end

--- Selects a window and then focuses it.
--- @param opts table: Optional options that may override global options.
--- @return boolean: Whether a window has been selected and focused.
function M.focus(opts)
	local win = M.select(opts)
	if not win then
		return false
	end

	api.nvim_set_current_win(win)

	return true
end

--- Sets up the plug-in by overriding default options.
--- @param opts table: Options to be globally overridden.
function M.setup(opts)
	defaults = vim.tbl_deep_extend("force", internal.defaults, opts or {})
end

return M
