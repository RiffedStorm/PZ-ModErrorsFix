-- Riffed Patches: Bandits x Project Viewpoint world-menu guard
--
-- Bandits' BanditMenu.WorldContextMenuPre (OnPreFillWorldObjectContextMenu) reads
-- ISWorldObjectContextMenu.fetchVars.clickedSquare through
-- BanditCompatibility.GetClickedSquare() and immediately calls square:getZombie().
-- That square only exists after a real right-click. Project Viewpoint builds the
-- same menu on its own every frame to find lootable things, so clickedSquare is nil
-- there and Bandits throws:
--     attempted index: getZombie of non-table: null  (BanditMenu.lua:224)
--
-- Fix: Bandits' handler is swapped for a thin wrapper that skips it when there is no
-- clicked square (nothing to show a Bandits option for anyway). On a real
-- right-click the original handler runs exactly as before.
-- As a second line of defence, GetClickedSquare() returns an inert stand-in instead of
-- nil, so another caller can't crash on it either.
--
-- Does nothing if Bandits is not installed. Bandits itself is not edited.

local TAG = "[RiffedPatches] "

-- Stand-in square: every method returns nil.
local NULL_SQUARE = setmetatable({}, {
    __index = function() return function() return nil end end,
})

local patched = false

local function apply()
    if patched then return end
    if not (BanditMenu and type(BanditMenu.WorldContextMenuPre) == "function") then return end
    if not (BanditCompatibility and type(BanditCompatibility.GetClickedSquare) == "function") then return end
    if not (Events and Events.OnPreFillWorldObjectContextMenu) then return end
    patched = true

    local getSquare = BanditCompatibility.GetClickedSquare
    local function clickedSquare()
        local ok, sq = pcall(getSquare)
        if ok then return sq end
        return nil
    end

    -- 1) Skip the Bandits handler when there is no clicked square.
    local handler = BanditMenu.WorldContextMenuPre
    local function guarded(...)
        if clickedSquare() == nil then return end
        return handler(...)
    end
    local removed = pcall(Events.OnPreFillWorldObjectContextMenu.Remove, handler)
    if removed then
        Events.OnPreFillWorldObjectContextMenu.Add(guarded)
    end

    -- 2) Never hand nil to anything that calls GetClickedSquare().
    BanditCompatibility.GetClickedSquare = function()
        local sq = clickedSquare()
        if sq ~= nil then return sq end
        return NULL_SQUARE
    end

    print(TAG .. "Bandits menu guard active" .. (removed and "" or " (fallback mode)"))
end

apply()
if Events and Events.OnGameBoot then
    Events.OnGameBoot.Add(apply)
end
if Events and Events.OnGameStart then
    Events.OnGameStart.Add(apply)
end
