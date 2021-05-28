local RichTextParser            = require(script:WaitForChild("Parser"))
local dict                      = require(script:WaitForChild("dict-util"))
local parser                    = RichTextParser.new()

export type Word = {
    text: string,
    prefix: string,
    suffix: string
}

export type Dialogue = {
    speaker: string,
    words: {Word}
}

export type Parser = {
    parse: (string) -> Dialogue,
    flush: () -> nil
}

local exports                   = {}

local RichTextEvaluator         = {}
RichTextEvaluator.__index       = RichTextEvaluator

function RichTextEvaluator:init()
    self.lengthMap              = {}
    
    local currentPosition       = 0
    local tokenAccumulator      = ""

    for _, token in pairs(self.tokens) do
        for i=1, #token.text do
            currentPosition     += 1
            self.lengthMap[currentPosition] = tokenAccumulator .. token.prefix .. token.text:sub(1, i) .. token.suffix
        end
        tokenAccumulator        = tokenAccumulator .. token.prefix .. token.text .. token.suffix
    end

    self.length                 = currentPosition
    return self
end

function RichTextEvaluator:__len()
    return self.length
end

function RichTextEvaluator:__call(startIndex, endIndex)
    if not endIndex then
        return self:eval(startIndex)
    else
        local out = self:eval(endIndex)
        return out:sub(startIndex, #out)
    end
end

function RichTextEvaluator:eval(n)
    return self.lengthMap[n]
end

RichTextEvaluator.string        = RichTextEvaluator.eval

local function evaluator(tokens): Parser
    return setmetatable({
        tokens = dict.deepCopy(tokens)
    }, RichTextEvaluator):init()
end

function exports.new(...)
    local eval = evaluator(parser.parse(...)); parser.flush()
    return eval
end

return exports