-- B42 Body Location Patch: world context menu null-sprite guard
--
-- Project Viewpoint (and possibly other mods) call
-- ISWorldObjectContextMenu.createMenu with a list that can contain objects
-- without a sprite name. Build 42.21's Java ISWorldObjectContextMenuLogic.fetch
-- does spriteName.equals(...) without a null check and throws a
-- NullPointerException every frame.
--
-- This wraps createMenu so entries that have no sprite name are dropped from the
-- list before vanilla sees them. Entries that vanilla could already handle are
-- left untouched, and nothing in other mods is edited.

local TAG = "[B42BodyLocationPatch] "

local function hasSpriteName(o)
    if o == nil then return false end
    local ok, res = pcall(function()
        -- Plain Lua tables or non-IsoObject things: leave alone.
        if o.getSpriteName then
            return o:getSpriteName() ~= nil
        end
        if o.getSprite then
            local spr = o:getSprite()
            if spr == nil then return false end
            return spr:getName() ~= nil
        end
        return true
    end)
    if not ok then return false end
    return res
end

local function filterObjects(list)
    if type(list) ~= "table" then return list, 0 end
    local out, dropped = {}, 0
    for _, o in ipairs(list) do
        if hasSpriteName(o) then
            out[#out + 1] = o
        else
            dropped = dropped + 1
        end
    end
    if dropped == 0 then return list, 0 end
    return out, dropped
end

local wrapped = false
local loggedDrop, loggedFail = false, false

local function wrap()
    if wrapped then return end
    if not ISWorldObjectContextMenu or type(ISWorldObjectContextMenu.createMenu) ~= "function" then
        return
    end
    wrapped = true

    local original = ISWorldObjectContextMenu.createMenu

    ISWorldObjectContextMenu.createMenu = function(player, worldobjects, ...)
        local filtered, dropped = filterObjects(worldobjects)
        if dropped > 0 and not loggedDrop then
            loggedDrop = true
            print(TAG .. "dropped " .. dropped .. " world object(s) with no sprite name from the context menu")
        end
        local ok, res = pcall(original, player, filtered, ...)
        if not ok then
            if not loggedFail then
                loggedFail = true
                print(TAG .. "createMenu still failed after filtering: " .. tostring(res))
            end
            return nil
        end
        return res
    end

    print(TAG .. "context menu guard active")
end

wrap()
if Events and Events.OnGameStart then
    Events.OnGameStart.Add(wrap)
end
if Events and Events.OnGameBoot then
    Events.OnGameBoot.Add(wrap)
end
