local internal = require("winpick.internal")

local api = vim.api

describe("winpick internal API", function()
	after_each(function()
		local open_wins = vim.list_slice(api.nvim_list_wins(), 2)
		for _, winid in ipairs(open_wins) do
			api.nvim_win_close(winid, true)
		end

		local open_bufs = api.nvim_list_bufs()
		for _, bufnr in ipairs(open_bufs) do
			api.nvim_buf_delete(bufnr, { force = true })
		end
	end)

	it("should correctly show visual cues with correct labels", function()
		local winid = api.nvim_get_current_win()
		local bufnr = api.nvim_create_buf(true, false)

		api.nvim_win_set_buf(winid, bufnr)
		api.nvim_buf_set_name(bufnr, "foobar")

		local cues = internal.show_cues({ A = { id = winid, bufnr = bufnr } }, internal.defaults)
		local cue_buf = api.nvim_win_get_buf(cues[1])

		local want = {
			"                 ",
			"    A: foobar    ",
			"                 ",
			"",
		}

		assert.same(want, api.nvim_buf_get_lines(cue_buf, 0, -1, true))
	end)

	it("should correctly show visual cues with custom labels", function()
		local winid = api.nvim_get_current_win()
		local bufnr = api.nvim_create_buf(true, false)

		api.nvim_win_set_buf(winid, bufnr)
		api.nvim_buf_set_name(bufnr, "foobar")

		local opts = vim.tbl_extend("force", internal.defaults, {
			format_label = function(label, _, _)
				return "testing: " .. label
			end,
		})

		local cues = internal.show_cues({ A = { id = winid, bufnr = bufnr } }, opts)
		local cue_buf = api.nvim_win_get_buf(cues[1])

		local want = {
			"                  ",
			"    testing: A    ",
			"                  ",
			"",
		}

		assert.same(want, api.nvim_buf_get_lines(cue_buf, 0, -1, true))
	end)

	it("should correctly hide visual cues", function()
		local bufnr1 = api.nvim_get_current_buf()

		vim.cmd("wincmd v")

		local open_wins = api.nvim_tabpage_list_wins(0)
		local bufnr2 = api.nvim_create_buf(true, false)

		api.nvim_win_set_buf(open_wins[1], bufnr2)
		api.nvim_buf_set_name(bufnr2, "foobar")

		local cues = internal.show_cues({
			A = { id = open_wins[1], bufnr = bufnr1 },
			B = { id = open_wins[2], bufnr = bufnr2 },
		}, internal.defaults)

		api.nvim_win_close(cues[1], true) -- make sure hide_cues won't fail despite this being missing
		internal.hide_cues(cues)

		assert.same(open_wins, api.nvim_tabpage_list_wins(0))
	end)

	it("should correctly handle nil label formatting function", function()
		local winid = api.nvim_get_current_win()
		local bufnr = api.nvim_create_buf(true, false)

		api.nvim_win_set_buf(winid, bufnr)
		api.nvim_buf_set_name(bufnr, "foobar")

		local opts = vim.tbl_extend("force", internal.defaults, {
			format_label = false,
		})

		local cues = internal.show_cues({ A = { id = winid, bufnr = bufnr } }, opts)
		local cue_buf = api.nvim_win_get_buf(cues[1])

		local want = {
			"         ",
			"    A    ",
			"         ",
			"",
		}

		assert.same(want, api.nvim_buf_get_lines(cue_buf, 0, -1, true))
	end)
end)
