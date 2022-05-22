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

		winpick.setup() -- reset config
	end)

	describe("setup", function()
		it("should not overwrite internal defaults", function()
			winpick.setup({ border = false })

			assert.equals("double", internal.defaults.border)
		end)
	end)

	-- TODO: Add tests with custom options.
	-- TODO: Add tests for cancel events.

	describe("for single window scenarios", function()
		it("should not show visual cue but still select current window", function()
			local win = winpick.select()

			assert.stub(vim.fn.getchar).was_not_called()
			assert.stub(internal.show_cues).was_not_called()
			assert.stub(internal.hide_cues).was_not_called()
			assert.equals(api.nvim_get_current_win(), win)
		end)

		it("should not show visual cue but still focus current window", function()
			local has_focused = winpick.focus()

			assert.stub(vim.fn.getchar).was_not_called()
			assert.stub(internal.show_cues).was_not_called()
			assert.stub(internal.hide_cues).was_not_called()
			assert.is_true(has_focused)
		end)
	end)

	describe("for multiple window scenarios", function()
		it("should show visual cues and select the chosen window", function()
			internal.show_cues.returns({ 1, 2 })
			vim.fn.getchar.returns(string.byte("A"))

			vim.cmd("wincmd v")

			local open_wins = api.nvim_tabpage_list_wins(0)
			local win = winpick.select()

			assert.stub(vim.fn.getchar).was_called()
			assert.stub(internal.show_cues).was_called_with({ A = open_wins[1], B = open_wins[2] }, internal.defaults)
			assert.stub(internal.hide_cues).was_called_with({ 1, 2 })
			assert.equals(win, open_wins[1])
		end)

		it("should show visual cues and focus the chosen window", function()
			internal.show_cues.returns({ 1, 2 })
			vim.fn.getchar.returns(string.byte("A"))

			vim.cmd("wincmd v")

			local open_wins = api.nvim_tabpage_list_wins(0)
			local has_focused = winpick.focus()

			assert.stub(vim.fn.getchar).was_called()
			assert.stub(internal.show_cues).was_called_with({ A = open_wins[1], B = open_wins[2] }, internal.defaults)
			assert.stub(internal.hide_cues).was_called_with({ 1, 2 })
			assert.equals(open_wins[1], api.nvim_get_current_win())
			assert.is_true(has_focused)
		end)
	end)
end)
