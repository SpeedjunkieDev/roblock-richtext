local function random(t, min, max)
    return t[math.random(min or 1, max or #t)]
end

local function splitPairs(t)
    local keys, values = {}, {}

    for k, v in pairs(t) do
        table.insert(keys,   k)
        table.insert(values, v)
    end

    return keys, values
end

local function arrayShallowCopy(t)
    local t2 = {}

    for i,v in pairs(t) do
        t2[i] = v
    end

    return t2
end

local function arrayDeepCopy(t)
    local t2 = {}

    for i,v in pairs(t) do
        if type(v) == "table" then
            t2[i] = arrayDeepCopy(v)
        elseif typeof(v) == "Instance" then
            t2[i] = v:Clone()
        else
            t2[i] = v
        end
    end

    return t2
end

local function arrayDeepMerge(a, b, write, avoid_paths, current_path)
    if write then
        current_path = current_path or ""
        avoid_paths  = avoid_paths or {}
        
        if avoid_paths[current_path] then return a end

        for i, v in pairs(b) do
            if typeof(a[i]) == "table" then
                arrayDeepMerge(a[i], v, true, avoid_paths, current_path .. i .. "/")
            else
                a[i] = v 
            end
        end

        
        return a
    end

    local t = {}

    for i, v in pairs(a) do
        t[i] = v 
    end

    for i, v in pairs(b) do
        if typeof(t[i]) == "table" then
            t[i] = arrayDeepMerge(t[i], v)
        else
            t[i] = v 
        end
    end

    return t
end

local function concatArrayAndMerge(a: {}, b: {})
    local t = {}

    for i, v in pairs(a) do
        if typeof(i) == "number" and typeof(v) ~= "table" then
            table.insert(t, v)
        else
            t[i] = v 
        end
    end

    for i, v in pairs(b) do
        if typeof(i) == "number" and typeof(v) ~= "table" then
            table.insert(t, v)
        elseif typeof(t[i]) == "table" then
            t[i] = concatArrayAndMerge(t[i], v)
        else
            t[i] = v
        end
    end

    return t
end

local function arrayMerge(a, b)
    local t = {}

    for i, v in pairs(a) do
        t[i] = v
    end

    for i, v in pairs(b) do
        t[i] = v
    end

    return t
end

local function arrayMergeAll(...)
    local arrays = {...}
    local out = table.remove(arrays, 1)

    for _, array in pairs(arrays) do
        for k, v in pairs(arrays) do
            out[k] = v
        end
    end

    return out
end

local function arrayDeepMergeAll(...)
    local arrays = {...}
    local out = table.remove(arrays, 1)

    for _, array in pairs(arrays) do
        out = arrayDeepMerge(out, array)
    end

    return out
end

local function map(t, predicate)
    local t2 = {}
    for i, v in pairs(t) do
        local v2, i2    = predicate(v, i)
        t2[i2 or i]     = v2
    end
    return t2
end

local function sort(t, comparator)
    table.sort(t, comparator)
    return t
end

local function multimap(t, ...)
    local argv  = {...}
    local t2    = t
    for _, predicate in pairs(argv) do
        t2      = map(t2, predicate)
    end
    return t2
end

local function filter(t, predicate)
    local t2 = {}
    for i, v in pairs(t) do
        if predicate(v, i) then
            if type(i) == "number" then
                table.insert(t2, v)
            else
                t2[i] = v
            end
        end
    end
    return t2
end

-- xd get it because filter + iterator
local function filterator(t, predicateGenerator)
    local t2 = t
    local pass, predicate

    while not pass do
        pass, predicate = predicateGenerator(t)
        
        if pass then
            return t2
        end

        t   = t2
        t2  = {}

        for i, v in pairs(t) do
            if predicate(v, i) then
                if type(i) == "number" then
                    table.insert(t2, v)
                else
                    t2[i] = v
                end
            end
        end
    end
    return t2
end

local function remove(t, t2)
    for i,v in pairs(t2) do
        table.remove(t, table.find(t, v))
    end
end

local function reduce(array: {any}, f: (any, any) -> any)
    local accumulator = array[1]
    for i=2, #array do
        accumulator = f(accumulator, array[i])
    end
    return accumulator
end

local function invert(dict: {[any]: any}): {[any]: any}
    local out = {}
    for key, value in pairs(dict) do
        out[value] = key
    end
    return out
end

local function join(...)
    local arrays = {...}
    local output = {}

    for n=1, #arrays do
        for i=1, #arrays[n] do
            table.insert(output, arrays[n][i])
        end
    end

    return output
end

local function forEach(array, callback)
    for i, v in pairs(array) do
        callback(v, i)
    end
end

local function alwaysFalse()
    return false
end

local function flattenArray(array, optionalFilter)
    local out = {}
    optionalFilter = optionalFilter or alwaysFalse

    for i=1, #array do
        if type(array[i]) == "table" then
            if optionalFilter(array[i]) then
                table.insert(out, array[i])
            else
                array[i] = flattenArray(array[i], optionalFilter)
                for j=1, #array[i] do
                    table.insert(out, array[i][j])
                end
            end
        else 
            table.insert(out, array[i])
        end
    end

    return out
end

local function flatten(dict: {}, optionalFilter)
    local out = {}
    optionalFilter = optionalFilter or alwaysFalse

    for i, v in pairs(dict) do
        if type(v) == "table" then
            if optionalFilter(v) then
                table.insert(out, v)
            else
                v = flatten(v, optionalFilter)
                for k, value in pairs(v) do
                    table.insert(out, value)
                end
            end
        else 
            table.insert(out, v)
        end
    end

    return out
end

local function reverse(t)
    local n, o = 0, {}
    for i=#t, 1, -1 do
        n    += 1
        o[n] = t[i]
    end
    return o
end

local function loop(item, times)
    local t = {}
    for i=1, times do
        table.insert(t, item)
    end
    return t
end

local function iequals(t, t2)
    for i=1, #t do
        if t[i] ~= t2[i] then
            return false
        end    
    end
    return true
end

local function keys(t)
    local key_v      = {}
    for k, _ in pairs(t) do
        table.insert(key_v, k)
    end
    return key_v
end

local function values(t)
    local value_v      = {}
    for _, v in pairs(t) do
        table.insert(value_v, v)
    end
    return value_v
end

local function unpackAnd(...)
    local f = {...}
    return function(argv)
        for n=1, #f do
            argv   = {f[n](unpack(argv))}
        end
        return unpack(argv)
    end
end

local function pack(...)
    return {...}
end

local Builder       = {}
Builder.__index     = Builder

function Builder.new(dict)
    return setmetatable({
        dict        = dict
    }, Builder)
end

function Builder:map(...)
    self.dict       = map(self.dict, ...)
    return self
end

function Builder:sort(...)
    self.dict       = sort(self.dict, ...)
    return self
end

function Builder:flatten(...)
    self.dict       = flatten(self.dict, ...)
    return self
end

function Builder:merge(...)
    self.dict       = arrayMerge(self.dict, ...)
    return self
end

function Builder:deepMerge(...)
    self.dict       = arrayDeepMerge(self.dict, ...)
    return self
end

function Builder:filter(...)
    self.dict       = filter(self.dict, ...)
    return self
end

function Builder:filterator(...)
    self.dict       = filterator(self.dict, ...)
    return self
end

function Builder:destroy()
    setmetatable(self, nil)
    local temp      = self.dict
    self.dict       = nil
    return temp
end

function Builder:reduce(...)
    return reduce(self:destroy(), ...)
end

function Builder:table()
    return self:destroy()
end

local function builder(dict)
    return Builder.new(dict)
end

return {
    flatten         = flatten,
    flattenArray    = flattenArray,
    merge           = arrayMerge,
    mergeAll        = arrayMergeAll,
    deepMerge       = arrayDeepMerge,
    deepMergeAll    = arrayDeepMergeAll,
    arrayDeepMerge  = concatArrayAndMerge,
    deepCopy        = arrayDeepCopy,
    copy        = arrayShallowCopy,
    multimap    = multimap,
    map         = map,
    filterator  = filterator,
    filter      = filter,
    reduce      = reduce,
    invert      = invert,
    loop        = loop,
    join        = join,
    concat      = join,
    forEach     = forEach,
    pairs       = splitPairs,
    push        = table.insert,
    reverse     = reverse,
    keys        = keys,
    values      = values,
    random      = random,
    pack        = pack,
    unpackAnd   = unpackAnd,
    remove      = remove,
    iequals     = iequals,
    sort        = sort,
    builder     = builder
}