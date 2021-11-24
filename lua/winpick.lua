local api = vim.api

local options = {
	border = "none",
}

local M = {}

local function clear_cues(cue_winids)
	for _, winid in pairs(cue_winids) do
		-- We use pcall here because we dont' want to throw an error just
		-- because we couldn't close a window that was probably already closed!
		pcall(api.nvim_win_close, winid, true)
	end
end

local function render_cues(winids)
	-- Reset view.
	local result = {}
	local floats = {}
	for idx, winid in ipairs(winids) do
		local ascii_code = idx + 64 -- A, B, C, ...
		local bufnr = api.nvim_create_buf(false, true)

		api.nvim_buf_set_lines(bufnr, 0, -1, false, {
			"         ",
			("    %s    "):format(vim.fn.nr2char(ascii_code)),
			"         ",
		})

		local width = 9
		local height = 3
		local float_winid = api.nvim_open_win(bufnr, false, {
			relative = "win",
			win = winid,
			width = width,
			height = height,
			col = math.floor(api.nvim_win_get_width(winid) / 2 - width / 2),
			row = math.floor(api.nvim_win_get_height(winid) / 2 - height / 2),
			focusable = false,
			style = "minimal",
			border = options.border,
		})

		table.insert(floats, float_winid)
		result[ascii_code] = winid
	end

	vim.cmd("redraw")
	return result, floats
end

local function focus_win(winid)
	-- TODO: Handle silent error.
	local ok = pcall(api.nvim_set_current_win, winid)
	return ok
end

local function prompt_for_ascii_code()
	vim.cmd("mode")
	while true do
		print("Pick a window: ")
		local ok, choice = pcall(vim.fn.getchar)
		vim.cmd("mode")
		if not ok or tonumber(choice) == 27 then -- handle Ctrl-C and Esc
			return
		end

		choice = vim.fn.nr2char(choice):upper()

		return vim.fn.char2nr(choice)
	end
end

-- Prompts the user for a window to be focused. In case there's only one viable window available, it
-- automatically picks that window instead.
--
-- It tries to apply some heuristics in order to pick the best window possible (listed, no buftype
-- or even a terminal), but falls back to them if no other "good" window is available.
--
-- @returns Whether a window has been picked and successfully focused
function M.pick_window()
	local winids = api.nvim_tabpage_list_wins(0)
	local recipient_winids

	-- Let's filter windows that shouldn't be used as recipients because of their specific types
	-- and, in case there is at least one listed window left for us to use as a recipient, we pick
	-- the filtered list, otherwise, we keep using unlisted windows.
	recipient_winids = vim.tbl_filter(function(winid)
		local bufnr = api.nvim_win_get_buf(winid)
		local buftype = api.nvim_buf_get_option(bufnr, "buftype")

		return buftype == "" or buftype == "terminal"
	end, winids)

	if #recipient_winids == 0 then
		recipient_winids = winids
	end

	if #recipient_winids == 1 then
		return focus_win(recipient_winids[1])
	end

	local ascii_win_map, cue_winids = render_cues(recipient_winids)
	if vim.tbl_isempty(ascii_win_map) then
		return false
	end

	local ascii_code = prompt_for_ascii_code()
	clear_cues(cue_winids)
	if not ascii_code then
		return false
	end

	local winid = ascii_win_map[ascii_code]
	if not winid then
		return false
	end

	return focus_win(winid)
end

-- Overrides default options.
function M.setup(opts)
	options = vim.tbl_extend("force", options, opts or {})
end

return M
