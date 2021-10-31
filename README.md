# winpick

This is a very simple plugin to help with picking an open window.

## Usage
```lua
local winpick = require("winpick")

if winpick.pick_window() then
	-- Do your command here...
end
```

### Custom options
- `border`: Border style passed to `nvim_open_win`, defaults to `"none"`

#### Example
```lua
local winpick = require("winpick")

-- These are the default options.
winpick.setup({
	border = "none",
})
```
