local InputStream   = {}
InputStream.__index = InputStream

function InputStream.new(src)
    return setmetatable({
        src         = src,
        pos         = 0,
        line        = 1,
        col         = 1
    }, InputStream)
end

function InputStream:next()
    local ch        = string.sub(self.src, self.pos, self.pos)
    self.pos        += 1

    if ch == "\n" then
        self.line   += 1
        self.col    = 1
    else
        self.col    += 1
    end

    return ch
end

function InputStream:peek()
    return string.sub(self.src, self.pos, self.pos)
end

function InputStream:eof()
    return self.pos > #self.src
end

function InputStream:throw()
    error("Error at ("..self.line..":"..self.col..")")
end

return InputStream