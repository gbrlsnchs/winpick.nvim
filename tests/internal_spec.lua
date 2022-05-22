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
		local win = api.nvim_get_current_win()
		local bufnr = api.nvim_create_buf(true, false)

		api.nvim_win_set_buf(win, bufnr)
		api.nvim_buf_set_name(bufnr, "foobar")

		local cues = internal.show_cues({ A = win, }, internal.defaults)
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
		local win = api.nvim_get_current_win()
		local bufnr = api.nvim_create_buf(true, false)

		api.nvim_win_set_buf(win, bufnr)
		api.nvim_buf_set_name(bufnr, "foobar")

		local opts = vim.tbl_extend("force", internal.defaults, {
			label_func = function(label)
				return "testing: " .. label
			end,
		})

		local cues = internal.show_cues({ A = win, }, opts)
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
		vim.cmd("wincmd v")

		local open_wins = api.nvim_tabpage_list_wins(0)
		local bufnr = api.nvim_create_buf(true, false)

		api.nvim_win_set_buf(open_wins[1], bufnr)
		api.nvim_buf_set_name(bufnr, "foobar")

		local cues = internal.show_cues({
			A = open_wins[1],
			B = open_wins[2],
		}, internal.defaults)

		api.nvim_win_close(cues[1], true) -- make sure hide_cues won't fail despite this being missing
		internal.hide_cues(cues)

		assert.same(open_wins, api.nvim_tabpage_list_wins(0))
	end)
end)
