local ADDON_NAME, GoldPlanner = ...;
local EVENTS = GoldPlanner.EVENTS;

GoldPlanner.name = ADDON_NAME;
GoldPlanner.version = C_AddOns.GetAddOnMetadata(ADDON_NAME, "Version");

local function log(...)
    local message = string.format(...);
    print("|cffffd100" .. ADDON_NAME .. "|r: " .. message);
end

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

        log("v" .. GoldPlanner.version .. " loaded.");
    elseif event == EVENTS.PLAYER_ENTERING_WORLD then
        GoldPlanner:UpdateCharacterCopper();
        GoldPlanner:UpdateWarbandCopper();
        
        log("Character: " .. GetMoneyString(GoldPlanner:GetCharacter().copper, true));
        log("Warband: " .. GetMoneyString(GoldPlanner.db.warband.copper, true));
        log("Total: " .. GetMoneyString(GoldPlanner:GetTotalCopper(), true));
    elseif event == EVENTS.PLAYER_MONEY then
        -- log("PLAYER_MONEY");
        GoldPlanner:UpdateCharacterCopper();
        -- log("Character: " .. GetMoneyString(GoldPlanner:GetCharacter().copper, true));
        -- log("Total: " .. GetMoneyString(GoldPlanner:GetTotalCopper(), true));
    elseif event == EVENTS.ACCOUNT_MONEY then
        -- log("ACCOUNT_MONEY");
        GoldPlanner:UpdateWarbandCopper();
        -- log("Warband: " .. GetMoneyString(GoldPlanner.db.warband.copper, true));
        -- log("Total: " .. GetMoneyString(GoldPlanner:GetTotalCopper(), true));
    end
end);