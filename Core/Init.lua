local ADDON_NAME, GoldPlanner = ...;
local EVENTS = GoldPlanner.EVENTS;

GoldPlanner.name = ADDON_NAME;
GoldPlanner.version = C_AddOns.GetAddOnMetadata(ADDON_NAME, "Version");

local function RegisterSlashCommands()
    SLASH_GOLDPLANNER1 = GoldPlanner.STRINGS.SLASH_COMMAND;
    SLASH_GOLDPLANNER2 = GoldPlanner.STRINGS.SLASH_COMMAND_SHORT;

    SlashCmdList["GOLDPLANNER"] = function()
        GoldPlanner:ToggleDashboard();
    end
end

local function HandleEvents(self, event, ...)
    if event == EVENTS.ADDON_LOADED then
        local loadedAddonName = ...;

        if loadedAddonName ~= ADDON_NAME then
            return;
        end

        GoldPlanner:InitializeDatabase();
        GoldPlanner:BuildDashboard();
        RegisterSlashCommands();
    elseif event == EVENTS.PLAYER_ENTERING_WORLD then
        GoldPlanner:UpdateCharacterCopper();
        GoldPlanner:UpdateWarbandCopper();
        GoldPlanner:UpdateDashboard();
    elseif event == EVENTS.PLAYER_MONEY then
        GoldPlanner:UpdateCharacterCopper();
        GoldPlanner:UpdateDashboard();
    elseif event == EVENTS.ACCOUNT_MONEY then
        GoldPlanner:UpdateWarbandCopper();
        GoldPlanner:UpdateDashboard();
    end
end

local eventFrame = CreateFrame("Frame");
eventFrame:RegisterEvent(EVENTS.ADDON_LOADED);
eventFrame:RegisterEvent(EVENTS.PLAYER_MONEY);
eventFrame:RegisterEvent(EVENTS.ACCOUNT_MONEY);
eventFrame:RegisterEvent(EVENTS.PLAYER_ENTERING_WORLD);
eventFrame:SetScript("OnEvent", HandleEvents);