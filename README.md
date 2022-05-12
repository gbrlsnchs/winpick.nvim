# winpick

This is a very simple plugin to help with picking an open window.

## Usage
```lua
local winpick = require("winpick")

local win = winpick.select()
print(win)

local has_focused = winpick.focus()
print(has_focused)
```

### Custom options
Options can be set in `setup` and also as first parameter of `select`:

| Option | Description | Default value |
|--------|-------------|---------------|
| `border` | Border style passed internally to `nvim_open_win`. | `"double"` |
| `buf_excludes` | Set of buffer options that help detecting buffers to avoid. Accepts either single values of lists of values. | `{ buftype = "quickfix" }` |
| `win_excludes` | Set of window options that help detecting windows to avoid. Accepts either single values of lists of values. | `{ previewwindow = true }` |

#### Example
```lua
local winpick = require("winpick")

winpick.setup({
	border = "none",
	buf_excludes = {
		buftype = { "quickfix", "terminal" }
		filetype = "NvimTree",
	},
	win_excludes = false, -- won't check window options
})
```

Scoped options can also be passed to `winpick.select` and `winpick.focus`, which will override the
global config or fall back to it altogether in case nothing is passed.
