local api = vim.api

--- Shows label and buffer name, if available. Else, show only the label.
--- @param win number: ID of the selected window.
--- @param label string: Label to be shown alongside the buffer name.
--- @return string: The label as is.
local function format_label(label, win)
	local bufnr = api.nvim_win_get_buf(win)
	local buf_name = api.nvim_buf_get_name(bufnr)

	if buf_name:len() == 0 then
		return label
	end

	return string.format("%s: %s", label, vim.fn.fnamemodify(buf_name, ":~:."))
end

local M = {}

M.defaults = {
	border = "double",
	buf_excludes = {
		buftype = "quickfix",
	},
	win_excludes = {
		previewwindow = true,
	},
	prompt = "Pick a window: ",
	label_func = format_label,
}

--- Maps a table index to an ASCII character starting from A (1 is A, 2 is B, and so on).
--- @param idx number: Index of a table.
--- @return number: The respective ASCII character.
function M.format_index(idx)
	return string.char(idx + 64)
end

--- Shows visual cues for each window.
--- @param targets table: Map of labels and their respective window IDs.
--- @param opts table: Options for showing visual cues.
--- @return table: List of visual cues that were opened.
function M.show_cues(targets, opts)
	-- Reset view.
	local cues = {}
	for label, win in pairs(targets) do
		local bufnr = api.nvim_create_buf(false, true)

		label = opts.label_func(label, win)

		local padding = string.rep(" ", 4)
		local fill = string.rep(" ", label:len())

		local lines = {
			padding .. fill .. padding,
			padding .. label .. padding,
			padding .. fill .. padding,
		}

		api.nvim_buf_set_lines(bufnr, 0, 0, false, lines)

		local width = label:len() + padding:len() * 2
		local height = 3

		local center_x = api.nvim_win_get_width(win) / 2
		local center_y = api.nvim_win_get_height(win) / 2

		local cue_win = api.nvim_open_win(bufnr, false, {
			relative = "win",
			win = win,
			width = width,
			height = height,
			col = math.floor(center_x - width / 2),
			row = math.floor(center_y - height / 2),
			focusable = false,
			style = "minimal",
			border = opts.border,
		})

		pcall(api.nvim_buf_set_option, cue_win, "buftype", "nofile")

		table.insert(cues, cue_win)
	end

	return cues
end

--- Closes all windows for visual cues.
function M.hide_cues(cues)
	for _, win in pairs(cues) do
		-- We use pcall here because we dont' want to throw an error just
		-- because we couldn't close a window that was probably already closed!
		pcall(api.nvim_win_close, win, true)
	end
end

return M
