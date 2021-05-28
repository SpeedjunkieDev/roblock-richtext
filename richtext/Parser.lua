local tokenizer         = require(script.Parent:WaitForChild("Tokenizer"))
local dict              = require(script.Parent:WaitForChild("dict-util"))

local parser            = {}

function parser.new()
    local lexer

    local function clear()
        lexer:flush()
        lexer   = nil
    end

    local function parse(text)
        lexer   = tokenizer.new(text)

        while lexer:available() do
            lexer:read_next()
        end

        local tokens = dict.builder(lexer.tokens)
            :map(function(e)
                if e[1] == "<" then
                    if e[2] == '/' then
                        return {
                            token   = table.concat(e),
                            type    = "modifier",
                            close   = true
                        }
                    end
                    return {
                        token       = table.concat(e),
                        type        = "modifier",
                        open        = true
                    }
                end

                return {
                    token           = table.concat(e),
                    type            = "string"
                }
            end)
            :map(function(e)
                if e.type           == "modifier" then
                    e.tag           = e.token:match("%l+")
                end
                return e
            end)
            :table()

        local stack                 = {}

        local function find(tag)
            for i=#stack, 1, -1 do
                if stack[i].tag == tag then
                    return i
                end
            end
            return -1
        end

        local function getToken(tokenObject)
            return tokenObject.token
        end

        local function getTag(tokenObject)
            return "</" .. tokenObject.tag .. ">"
        end

        local output                = {}

        for n=1, #tokens do
            local token     = tokens[n]
            if token.type == 'modifier' then
                if token.open then
                    table.insert(stack, token)
                elseif token.close then
                    table.remove(stack, find(token.tag))
                end
            elseif token.type == "string" then
                table.insert(output, {
                    text    = token.token,
                    prefix  = table.concat(dict.map(stack, getToken)),
                    suffix  = table.concat(dict.map(dict.reverse(stack), getTag))
                })
            end
        end

        return output
    end

    return { parse  = parse, flush = clear }
end

return parser