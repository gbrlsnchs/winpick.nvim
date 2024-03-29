# winpick.nvim

[![winpick.nvim
CI](https://github.com/gbrlsnchs/winpick.nvim/actions/workflows/ci.yml/badge.svg)](https://github.com/gbrlsnchs/winpick.nvim/actions/workflows/ci.yml)

![Example of how winpick works](https://i.imgur.com/4xACRUJ.png)

Plugin that helps with picking windows.

## Installation
Use whichever plugin management practices you prefer. Personally I like Neovim's built-in plugin
management system (`:help packages`) combined with Git submodules, but that choice is up to you!

## Usage

> Note: use `:help winpick.txt` for a Vim friendly documentation.

This plugin is a single-function library that helps with picking a window inside Neovim.

Basically, it shows visual cues with labels assigned to them. Meanwhile, it also prompts the user
with a label. Once the user presses the respective key to a label, the function returns the selected
window's ID and its corresponding buffer ID, or just `nil` if no window is selected.

## Setup
Here an example with all default options:
```lua
winpick.setup({
	border = "double",
	filter = nil, -- doesn't ignore any window by default
	prompt = "Pick a window: ",
	format_label = winpick.defaults.format_label, -- formatted as "<label>: <buffer name>"
	chars = nil,
})
```

## Options
From `:help winpick-options`:
```vimhelp
• border (string) Style of visual cues' borders. Defaults to `double`.

• filter (function) Predicate function that receives a target window's
corresponding ID and buffer ID and returns whether that window is eligible
for being picked. Defaults to `nil`, thus not ignoring any window.

• prompt (string) Prompt message when cues are visible.

• format_label (function) Function that formats the labels for visual
cues. It receives the target window ID as first parameter and the
corresponding label for the visual cue (A, B, C, etc). Defaults to
printing the respective label and the buffer name, if any.

• chars (table) List containing `n` characters that will be used for labels
in the first `n` visual cues opened. For a number of windows greater than
`n`, complementary characters will be additionally used. Defaults to `nil`,
and a default alphabet is used.
```

## Some examples
<details>
<summary>Moving to a window</summary>

```lua
local winid = winpick.select()

if winid then
	vim.api.nvim_set_current_win(winid)
end
```

</details>

<details>
<summary>Copying a buffer's path</summary>

```lua
local winid, bufnr = winpick.select({
	filter = function(winid, bufnr, default_filter)
		if vim.api.nvim_buf_get_option(bufnr, "buftype") == "terminal" then
			return false
		end

		return default_filter(winid, bufnr)
	end,
})

if not winid then
	return
end

local name = api.nvim_buf_get_name(bufnr)
if name then
	vim.fn.setreg("+", vim.fn.fnamemodify(name, ":~:."))
end
```

</details>
