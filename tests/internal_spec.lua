local internal = require("winpick.internal")

local api = vim.api

describe("winpick internal API", function()
	after_each(function()
		local open_wins = vim.list_slice(api.nvim_list_wins(), 2)
		for _, win in ipairs(open_wins) do
			api.nvim_win_close(win, true)
		end

		local open_bufs = api.nvim_list_bufs()
		for _, bufnr in ipairs(open_bufs) do
			api.nvim_buf_delete(bufnr, { force = true })
		end
	end)

	it("should correctly show visual cues with correct labels", function()
		vim.cmd("wincmd v")

		local open_wins = api.nvim_tabpage_list_wins(0)
		local bufnr = api.nvim_create_buf(true, false)

		api.nvim_win_set_buf(open_wins[1], bufnr)
		api.nvim_buf_set_name(bufnr, "foobar")

		local cues = internal.show_cues({
			A = open_wins[1],
			B = open_wins[2],
		})

		local cue1_buf = api.nvim_win_get_buf(cues[1])
		local cue2_buf = api.nvim_win_get_buf(cues[2])

		local expects = {
			[cue1_buf] = {
				"                 ",
				"    A: foobar    ",
				"                 ",
				"",
			},
			[cue2_buf] = {
				"         ",
				"    B    ",
				"         ",
				"",
			},
		}

		assert.same(api.nvim_buf_get_lines(cue1_buf, 0, -1, true), expects[cue1_buf])
		assert.same(api.nvim_buf_get_lines(cue2_buf, 0, -1, true), expects[cue2_buf])
	end)

	it("should correctly hide visual cues", function()
		vim.cmd("wincmd v")

		local open_wins = api.nvim_tabpage_list_wins(0)
		local bufnr = api.nvim_create_buf(true, false)

		api.nvim_win_set_buf(open_wins[1], bufnr)
		api.nvim_buf_set_name(bufnr, "foobar")

		local cues = internal.show_cues({
			A = open_wins[1],
			B = open_wins[2],
		})

		api.nvim_win_close(cues[1], true) -- make sure hide_cues won't fail despite this being missing
		internal.hide_cues(cues)

		assert.same(open_wins, api.nvim_tabpage_list_wins(0))
	end)
end)
