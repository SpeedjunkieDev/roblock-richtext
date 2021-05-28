# roblox-richtext

## you need rojo to use this unless you import the files manually

```lua
local richtext  = import "richtext"

local mytext    = richtext.new("<b>Hello, <i>world!</i> My name is </b><u>Muneeb</u>")
mytext(1)       -- "<b>H</b>"
mytext(8)       -- "<b>Hello, <i>w</i></b>"

mytext(#mytext) -- "<b>Hello, <i>world!</i> My name is </b><u>Muneeb</u>"
```
