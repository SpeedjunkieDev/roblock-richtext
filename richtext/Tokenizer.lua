local exports           = {}

local InputStream       = require(script.Parent:WaitForChild("InputStream"))

local Tokenizer         = {}
Tokenizer.__index       = Tokenizer

function Tokenizer.new(src)
    return setmetatable({
        input           = InputStream.new(src),
        current         = {},
        tokens          = {}
    }, Tokenizer)
end

function Tokenizer:next()
    local char          = self.input:next()
    table.insert(self.current, char)
    return char
end

function Tokenizer:flush(kill)
    if not self.current then return end
    table.insert(self.tokens, self.current)
    self.current        = {}
    if kill then self.current = nil end
end

function Tokenizer:read_next()
    if (self.input:eof()) then return self:flush(true) end

    local ch            = self.input:peek()
    if ch == '<' then return self:read_tag() end
    return self:next()
    -- self.input:throw("Can't handle character: " + ch)
end

function Tokenizer:available()
    return not self.input:eof()
end

function Tokenizer:read_tag()
    self:flush()
    while self:next() ~= ">" do end
    self:flush()
end

function exports.new(...)
    return Tokenizer.new(...)
end

return exports