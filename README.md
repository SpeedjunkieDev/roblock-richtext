# roblox-richtext

## you need rojo to use this unless you import the files manually

```lua
local richtext  = require(path_to_richtext_module)

local mytext    = richtext.new("<b>Hello, <i>world!</i> My name is </b><u>Muneeb</u>")
mytext(1)         -- "<b>H</b>"
mytext(8)         -- "<b>Hello, <i>w</i></b>"
mytext:eval(1)    -- "<b>H</b>"
mytext:eval(8)    -- "<b>Hello, <i>w</i></b>"
mytext:string(1)  -- "<b>H</b>"

mytext(#mytext)   -- "<b>Hello, <i>world!</i> My name is </b><u>Muneeb</u>"
```
