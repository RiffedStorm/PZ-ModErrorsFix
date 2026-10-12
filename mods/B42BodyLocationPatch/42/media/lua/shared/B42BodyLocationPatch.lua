-- B42 Body Location Patch
-- Compatibility shim for Project Zomboid Build 42.21+.
--
-- Older mods call methods such as player:getWornItem("LeftWrist") with a plain
-- string. In current B42 builds the Java side wants an ItemBodyLocation object
-- and throws "expected argument of type ItemBodyLocation, got String".
-- This file wraps those methods so a string is converted to the matching
-- ItemBodyLocation first. If no match can be found, getters return nil
-- instead of throwing, so one outdated mod cannot spam errors every tick.
--
-- Nothing in other mods is replaced or edited.

local TAG = "[B42BodyLocationPatch] "

local cache = {}      -- string -> ItemBodyLocation (or false if unresolvable)
local warned = {}     -- strings we already logged a failure for

local function snake(s)
    return (s:gsub("(%l)(%u)", "%1_%2"):gsub("[%s%-]+", "_"):lower())
end

local function candidates(s)
    local list, seen = {}, {}
    local function add(x)
        if x and not seen[x] then seen[x] = true; list[#list + 1] = x end
    end
    local sn = snake(s)
    local flat = s:lower()
    if s:find(":", 1, true) then
        add(s)
    else
        add("base:" .. sn)
        add("base:" .. flat)
        add("base:" .. s)
        add(sn)
        add(flat)
        add(s)
    end
    return list
end

local function tryResolve(id)
    -- 1) ItemBodyLocation.get(ResourceLocation)
    if ItemBodyLocation and ItemBodyLocation.get and ResourceLocation and ResourceLocation.of then
        local ok, rl = pcall(ResourceLocation.of, id)
        if ok and rl then
            local ok2, res = pcall(ItemBodyLocation.get, rl)
            if ok2 and res then return res end
        end
    end
    -- 2) ItemBodyLocation.get(String)
    if ItemBodyLocation and ItemBodyLocation.get then
        local ok, res = pcall(ItemBodyLocation.get, id)
        if ok and res then return res end
    end
    -- 3) ItemBodyLocation.valueOf(String)
    if ItemBodyLocation and ItemBodyLocation.valueOf then
        local ok, res = pcall(ItemBodyLocation.valueOf, id)
        if ok and res then return res end
    end
    return nil
end

local function toLocation(v)
    if type(v) ~= "string" then return v end
    local c = cache[v]
    if c ~= nil then return c or nil end

    -- static field, e.g. ItemBodyLocation.LEFT_WRIST
    if ItemBodyLocation then
        local fieldName = snake(v):gsub("^base:", ""):upper()
        local ok, res = pcall(function() return ItemBodyLocation[fieldName] end)
        if ok and res and type(res) ~= "string" then
            cache[v] = res
            return res
        end
    end

    for _, id in ipairs(candidates(v)) do
        local res = tryResolve(id)
        if res then
            cache[v] = res
            return res
        end
    end

    cache[v] = false
    if not warned[v] then
        warned[v] = true
        print(TAG .. "could not map body location string '" .. v .. "'")
    end
    return nil
end

-- Wrap mt.__index[name]; the argument at position `argPos` (counting self as 1)
-- is converted when it is a string. `fallback` is returned if conversion fails.
local function wrapMethod(mt, className, name, argPos, fallback)
    if not mt or not mt.__index then return end
    local original = mt.__index[name]
    if type(original) ~= "function" and type(original) ~= "userdata" then return end

    mt.__index[name] = function(...)
        local args = { ... }
        local n = select("#", ...)
        local a = args[argPos]
        if type(a) == "string" then
            local converted = toLocation(a)
            if converted == nil then return fallback end
            args[argPos] = converted
        end
        return original(unpack(args, 1, n))
    end
end

local function classMeta(cls)
    if not cls or not __classmetatables then return nil end
    local ok, mt = pcall(function() return __classmetatables[cls.class] end)
    if ok then return mt end
    return nil
end

local applied = false
local function apply()
    if applied then return end
    applied = true

    local targets = {
        { IsoGameCharacter, "IsoGameCharacter" },
        { IsoPlayer,        "IsoPlayer" },
        { IsoZombie,        "IsoZombie" },
        { IsoSurvivor,      "IsoSurvivor" },
    }
    for _, t in ipairs(targets) do
        local mt = classMeta(t[1])
        if mt then
            wrapMethod(mt, t[2], "getWornItem", 2, nil)
            wrapMethod(mt, t[2], "setWornItem", 2, nil)
        end
    end

    local wornMt = classMeta(WornItems)
    if wornMt then
        wrapMethod(wornMt, "WornItems", "getItem", 2, nil)
        wrapMethod(wornMt, "WornItems", "setItem", 2, nil)
    end

    print(TAG .. "active")
end

apply()
