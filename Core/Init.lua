local ADDON_NAME, GoldPlanner = ...;
local EVENTS = GoldPlanner.EVENTS;

GoldPlanner.name = ADDON_NAME;
GoldPlanner.version = C_AddOns.GetAddOnMetadata(ADDON_NAME, "Version");

local eventFrame = CreateFrame("Frame");

eventFrame:RegisterEvent(EVENTS.ADDON_LOADED);
eventFrame:RegisterEvent(EVENTS.PLAYER_MONEY);
eventFrame:RegisterEvent(EVENTS.ACCOUNT_MONEY);
eventFrame:RegisterEvent(EVENTS.PLAYER_ENTERING_WORLD);

eventFrame:SetScript("OnEvent", function(self, event, ...)
    if event == EVENTS.ADDON_LOADED then
        local loadedAddonName = ...;

        if loadedAddonName ~= ADDON_NAME then
            return;
        end

        GoldPlanner:InitializeDatabase();
    elseif event == EVENTS.PLAYER_ENTERING_WORLD then
        GoldPlanner:UpdateCharacterCopper();
        GoldPlanner:UpdateWarbandCopper();
    elseif event == EVENTS.PLAYER_MONEY then
        GoldPlanner:UpdateCharacterCopper();
    elseif event == EVENTS.ACCOUNT_MONEY then
        GoldPlanner:UpdateWarbandCopper();
    end
end);