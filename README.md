# winpick

[![Codeberg CI](https://ci.codeberg.org/api/badges/gbrlsnchs/winpick.nvim/status.svg)](https://codeberg.org/gbrlsnchs/winpick.nvim/commits/branch/trunk)

![Example of how winpick works](https://i.imgur.com/4xACRUJ.png)

Plugin that helps with picking windows.

# Usage

> Note: use `:help winpick.txt` for a Vim friendly documentation.

This plugin is a single-function library that helps with picking a window inside Neovim.

Basically, it shows visual cues with labels assigned to them. Meanwhile, it also prompts the user
with a label. Once the user presses the respective key to a label, the function returns the selected
window's ID, or `nil` if no window is selected.

## API
### Setup
```lua
winpick.setup({
	border = "none",
	buf_excludes = {
		buftype = { "quickfix", "terminal" },
		filetype = "NvimTree",
	},
	win_excludes = false,
})

print(selected_win)
```

### Select a window
```lua
local selected_win = winpick.select()

-- Focus the selected window.
if selected_win then
	vim.api.nvim_set_current_win(selected_win)
end
```

# Options

- `border` (string) Style of visual cues' borders. Defaults to `double`.
- `buf_filter` (function) Predicate function that receives a buffer ID and returns whether its
  window is eligible for being picked. Defaults to ignoring quickfix.
- `win_filter` (function) Same as buf_filter, but receives a window ID instead. Defaults to ignoring
  preview window.
- `format_label` (function) Function that formats the labels for visual cues. It receives the target
  window ID as first parameter and the corresponding label for the visual cue (A, B, C, etc).
  Defaults to printing the respective label and the buffer name, if any.
