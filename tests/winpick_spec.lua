local winpick = require("winpick")
local internal = require("winpick.internal")
local stub = require("luassert.stub")

local api = vim.api

describe("winpick API", function()
	stub(vim.fn, "getchar")
	stub(internal, "show_cues")
	stub(internal, "hide_cues")

	after_each(function()
		local open_wins = vim.list_slice(api.nvim_list_wins(), 2)
		for _, win in ipairs(open_wins) do
			api.nvim_win_close(win, true)
		end

		vim.fn.getchar:clear()
		internal.show_cues:clear()
		internal.hide_cues:clear()

		-- reset config
		winpick.setup()
	end)

	-- TODO: Add tests with custom options.
	-- TODO: Add tests for cancel events.

	describe("for single window scenarios", function()
		it("should not show visual cue but still select current window", function()
			local winid, bufnr = winpick.select()

			assert.stub(vim.fn.getchar).was_not_called()
			assert.stub(internal.show_cues).was_not_called()
			assert.stub(internal.hide_cues).was_not_called()
			assert.equals(api.nvim_get_current_win(), winid)
			assert.equals(api.nvim_get_current_buf(), bufnr)
		end)
	end)

	describe("for multiple window scenarios", function()
		it("should show visual cues and select the chosen window", function()
			internal.show_cues.returns({ 1, 2 })
			vim.fn.getchar.returns(string.byte("A"))

			local bufnr1 = api.nvim_get_current_buf()
			vim.cmd("wincmd v")
			local bufnr2 = api.nvim_get_current_buf()

			local open_wins = api.nvim_tabpage_list_wins(0)
			local winid, bufnr = winpick.select()

			assert.stub(vim.fn.getchar).was_called()
			assert.stub(internal.show_cues).was_called_with({
				A = { id = open_wins[1], bufnr = bufnr1 },
				B = { id = open_wins[2], bufnr = bufnr2 },
			}, internal.defaults())
			assert.stub(internal.hide_cues).was_called_with({ 1, 2 })
			assert.equals(api.nvim_get_current_win(), winid)
			assert.equals(api.nvim_get_current_buf(), bufnr)
		end)
	end)

	describe("window and buffer filters", function()
		it("should not consider quickfix by default", function()
			internal.show_cues.returns({ 1, 2 })
			vim.fn.getchar.returns(string.byte("A"))

			local bufnr1 = api.nvim_get_current_buf()
			vim.cmd("wincmd v")
			local bufnr2 = api.nvim_get_current_buf()
			vim.cmd("botright copen")
			vim.cmd("wincmd w") -- returns to first window

			local open_wins = api.nvim_tabpage_list_wins(0)
			local winid, bufnr = winpick.select()

			assert.stub(vim.fn.getchar).was_called()
			assert.stub(internal.show_cues).was_called_with({
				A = { id = open_wins[1], bufnr = bufnr1 },
				B = { id = open_wins[2], bufnr = bufnr2 },
			}, internal.defaults())
			assert.stub(internal.hide_cues).was_called_with({ 1, 2 })
			assert.equals(api.nvim_get_current_win(), winid)
			assert.equals(api.nvim_get_current_buf(), bufnr)
		end)

		it("should not consider preview window by default", function()
			internal.show_cues.returns({ 1, 2 })
			vim.fn.getchar.returns(string.byte("A"))

			vim.opt.splitright = true
			local bufnr1 = api.nvim_get_current_buf()
			vim.cmd("wincmd v")
			local bufnr2 = api.nvim_get_current_buf()
			vim.cmd("wincmd v")
			api.nvim_win_set_option(api.nvim_get_current_win(), "previewwindow", true)
			vim.cmd("wincmd w")

			local open_wins = api.nvim_tabpage_list_wins(0)
			local winid, bufnr = winpick.select()

			assert.stub(vim.fn.getchar).was_called()
			assert.stub(internal.show_cues).was_called_with({
				A = { id = open_wins[1], bufnr = bufnr1 },
				B = { id = open_wins[2], bufnr = bufnr2 },
			}, internal.defaults())
			assert.stub(internal.hide_cues).was_called_with({ 1, 2 })
			assert.equals(api.nvim_get_current_win(), winid)
			assert.equals(api.nvim_get_current_buf(), bufnr)
		end)
	end)

	describe("defaults helper", function()
		it("should be a read-only version of the defaults table", function()
			assert.are.same(winpick.defaults, internal.defaults())
			assert.has_error(function()
				winpick.defaults.border = "none"
			end, "defaults are read-only")
		end)
	end)
end)
