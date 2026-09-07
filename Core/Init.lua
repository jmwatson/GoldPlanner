local ADDON_NAME, GoldPlanner = ...;
local EVENTS = GoldPlanner.EVENTS;

GoldPlanner.name = ADDON_NAME;
GoldPlanner.version = C_AddOns.GetAddOnMetadata(ADDON_NAME, "Version");

local eventFrame = CreateFrame("Frame");

eventFrame:RegisterEvent(EVENTS.ADDON_LOADED);
eventFrame:RegisterEvent(EVENTS.PLAYER_MONEY);

eventFrame:SetScript("OnEvent", function(self, event, ...)
    if event == EVENTS.ADDON_LOADED then
        local loadedAddonName = ...;
        local addonPrintName = GoldPlanner:ColorizeText(ADDON_NAME, GoldPlanner.COLORS.GOLD);

        if loadedAddonName ~= ADDON_NAME then
            return;
        end

        GoldPlanner:InitializeDatabase();
        GoldPlanner:UpdateCharacterGold();

        print(addonPrintName .. " v" .. GoldPlanner.version .. " loaded.");
        print("Current gold:", GetMoneyString(GetMoney(), true));
    elseif event == EVENTS.PLAYER_MONEY then
        GoldPlanner:UpdateCharacterGold();
    end
end);