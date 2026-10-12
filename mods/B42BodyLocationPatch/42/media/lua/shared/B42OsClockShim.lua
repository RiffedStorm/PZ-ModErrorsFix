-- B42 Body Location Patch: os.clock shim
-- "Immersive Overlays Retexture - Less Intrusive Version" (OverlaysExtanded.lua:270)
-- calls os.clock(), which does not exist in Project Zomboid's Lua environment.
-- This defines it from the game timer only if it is missing; the other mod is not edited.

if os and not os.clock then
    os.clock = function()
        if getTimestampMs then
            return getTimestampMs() / 1000;
        end
        return getTimestamp();
    end
end
