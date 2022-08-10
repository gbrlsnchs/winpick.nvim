# winpick

[![Codeberg CI](https://ci.codeberg.org/api/badges/gbrlsnchs/winpick.nvim/status.svg)](https://codeberg.org/gbrlsnchs/winpick.nvim/commits/branch/trunk)

![Example of how winpick works](https://i.imgur.com/4xACRUJ.png)

Plugin that helps with picking windows.

# Usage

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
	filter = winpick.defaults.filter, -- filters preview window and quickfix
	prompt = "Pick a window: ",
	format_label = winpick.defaults.format_label, -- formatted as "<label>: <buffer name>"
})
```

## Options
| Name           | Type     | Description                                                                                                                                                          | Default                                       |
|----------------|----------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------|-----------------------------------------------|
| `border`       | string   | Style of visual cues' borders.                                                                                                                                       | `"double"`                                    |
| `filter`       | function | Predicate function that receives a target window's corresponding ID and buffer ID and returns whether that window is eligible for being picked.                      | Filters preview window and quickfix.          |
| `prompt`       | string   | Prompt message when cues are visible.                                                                                                                                | `"Pick a window: "`                           |
| `format_label` | function | Function that formats the labels for visual cues. It receives the target window ID as first parameter and the corresponding label for the visual cue (A, B, C, etc). | Prints the label and the buffer name, if any. |

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
	filter = function(winid, bufnr)
		if vim.api.nvim_buf_get_option(bufnr, "buftype") == "terminal" then
			return false
		end

		return winpick.defaults.filter(winid, bufnr)
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
