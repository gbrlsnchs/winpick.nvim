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

		local cues = internal.show_cues({ A = { id = winid, bufnr = bufnr } }, internal.defaults())
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
		vim.cmd("wincmd v")

		local open_wins = api.nvim_list_wins()

		local bufnr1 = api.nvim_create_buf(true, false)
		api.nvim_buf_set_name(bufnr1, "foobar")
		api.nvim_win_set_buf(open_wins[1], bufnr1)

		local bufnr2 = api.nvim_create_buf(true, false)
		api.nvim_win_set_buf(open_wins[2], bufnr2)

		local opts = vim.tbl_extend("force", internal.defaults(), {
			chars = { "x", "y" },
		})
		local cues = internal.show_cues({
			X = { id = open_wins[1], bufnr = bufnr1 },
			Y = { id = open_wins[2], bufnr = bufnr2 },
		}, opts)

		-- HACK: Order of IDs for visual cues is not deterministic, so we sort it based on the
		-- window list and how we arranged parent windows.
		cues = vim.tbl_map(function(id)
			return { id = id, parent_win = api.nvim_win_get_config(id).win }
		end, cues)
		table.sort(cues, function(a)
			return open_wins[1] == a.parent_win
		end)
		cues = vim.tbl_map(function(cue)
			return cue.id
		end, cues)

		assert.same({
			"                 ",
			"    X: foobar    ",
			"                 ",
			"",
		}, api.nvim_buf_get_lines(api.nvim_win_get_buf(cues[1]), 0, -1, true))
		assert.same({
			"         ",
			"    Y    ",
			"         ",
			"",
		}, api.nvim_buf_get_lines(api.nvim_win_get_buf(cues[2]), 0, -1, true))
	end)

	it("should correctly show visual cues with custom label formatting", function()
		local winid = api.nvim_get_current_win()
		local bufnr = api.nvim_create_buf(true, false)

		api.nvim_win_set_buf(winid, bufnr)
		api.nvim_buf_set_name(bufnr, "foobar")

		local opts = vim.tbl_extend("force", internal.defaults(), {
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

		vim.opt.splitright = true
		vim.cmd("wincmd v")

		local open_wins = api.nvim_tabpage_list_wins(0)
		local bufnr2 = api.nvim_create_buf(true, false)

		api.nvim_win_set_buf(open_wins[2], bufnr2)
		api.nvim_buf_set_name(bufnr2, "foobar")

		local cues = internal.show_cues({
			A = { id = open_wins[1], bufnr = bufnr1 },
			B = { id = open_wins[2], bufnr = bufnr2 },
		}, internal.defaults())

		api.nvim_win_close(cues[1], true) -- make sure hide_cues won't fail despite this being missing
		internal.hide_cues(cues)

		assert.same(open_wins, api.nvim_tabpage_list_wins(0))
	end)

	it("should correctly handle nil label formatting function", function()
		local winid = api.nvim_get_current_win()
		local bufnr = api.nvim_create_buf(true, false)

		api.nvim_win_set_buf(winid, bufnr)
		api.nvim_buf_set_name(bufnr, "foobar")

		local opts = vim.tbl_extend("force", internal.defaults(), {
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

	it("should resolve the alphabet for label characters", function()
		assert.same({
			"N",
			"E",
			"O",
			"V",
			"I",
			"M",
			"A",
			"B",
			"C",
			"D",
			"F",
			"G",
			"H",
			"J",
			"K",
			"L",
			"P",
			"Q",
			"R",
			"S",
			"T",
			"U",
			"W",
			"X",
			"Y",
			"Z",
			"0",
			"1",
			"2",
			"3",
			"4",
			"5",
			"6",
			"7",
			"8",
			"9",
		}, internal.resolve_chars({ "N", "E", "O", "V", "I", "M" }))
	end)
end)
