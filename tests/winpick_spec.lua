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
		it("should take quickfix into account", function()
			internal.show_cues.returns({ 1, 2 })
			vim.fn.getchar.returns(string.byte("A"))

			local bufnr1 = api.nvim_get_current_buf()
			vim.cmd("wincmd v")
			local bufnr2 = api.nvim_get_current_buf()
			vim.cmd("botright copen")
			local bufnr3 = api.nvim_get_current_buf()
			vim.cmd("wincmd w") -- returns to first window

			local open_wins = api.nvim_tabpage_list_wins(0)
			local winid, bufnr = winpick.select()

			assert.stub(vim.fn.getchar).was_called()
			assert.stub(internal.show_cues).was_called_with({
				A = { id = open_wins[1], bufnr = bufnr1 },
				B = { id = open_wins[2], bufnr = bufnr2 },
				C = { id = open_wins[3], bufnr = bufnr3 },
			}, internal.defaults())
			assert.stub(internal.hide_cues).was_called_with({ 1, 2 })
			assert.equals(api.nvim_get_current_win(), winid)
			assert.equals(api.nvim_get_current_buf(), bufnr)
		end)

		it("should take preview window into account", function()
			internal.show_cues.returns({ 1, 2 })
			vim.fn.getchar.returns(string.byte("A"))

			vim.opt.splitright = true
			local bufnr1 = api.nvim_get_current_buf()
			vim.cmd("wincmd v")
			local bufnr2 = api.nvim_get_current_buf()
			vim.cmd("wincmd v")
			api.nvim_win_set_option(api.nvim_get_current_win(), "previewwindow", true)
			local bufnr3 = api.nvim_get_current_buf()
			vim.cmd("wincmd w")

			local open_wins = api.nvim_tabpage_list_wins(0)
			local winid, bufnr = winpick.select()

			assert.stub(vim.fn.getchar).was_called()
			assert.stub(internal.show_cues).was_called_with({
				A = { id = open_wins[1], bufnr = bufnr1 },
				B = { id = open_wins[2], bufnr = bufnr2 },
				C = { id = open_wins[3], bufnr = bufnr3 },
			}, internal.defaults())
			assert.stub(internal.hide_cues).was_called_with({ 1, 2 })
			assert.equals(api.nvim_get_current_win(), winid)
			assert.equals(api.nvim_get_current_buf(), bufnr)
		end)

		it("should pass down the default filter to secondary filters", function()
			local default_filter_stub = stub()
			default_filter_stub.returns(true)

			internal.show_cues.returns({ 1, 2 })
			vim.fn.getchar.returns(string.byte("A"))

			stub(api, "nvim_tabpage_list_wins")
			api.nvim_tabpage_list_wins.returns({ 0xC0FFEE, 999 })

			stub(api, "nvim_win_get_buf")
			api.nvim_win_get_buf.returns(0xDEC0DE)

			winpick.setup({ filter = default_filter_stub })
			winpick.select({
				filter = function(winid, bufnr, default_filter)
					return default_filter(winid, bufnr)
				end,
			})

			assert.stub(default_filter_stub).was_called_with(0xC0FFEE, 0xDEC0DE)

			api.nvim_tabpage_list_wins:clear()
			api.nvim_win_get_buf:clear()
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
