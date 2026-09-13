local ADDON_NAME, GoldPlanner = ...;
local EVENTS = GoldPlanner.EVENTS;

GoldPlanner.name = ADDON_NAME;
GoldPlanner.version = C_AddOns.GetAddOnMetadata(ADDON_NAME, "Version");

local function HandleSlashCommand(parameters)
    local command, value = parameters:match("^(%S+)%s*(.*)$");
    local usage = "Usage: /gp goal <gold amount>";

    if command == "goal" then
        local gold = tonumber(value);

        if not gold or gold <= 0 then
            GoldPlanner:Log(usage);
            return;
        end

        GoldPlanner:SetGoal(gold * 10000);
        GoldPlanner:UpdateDashboard();

        GoldPlanner:Log("Goal set to", GetMoneyString(GoldPlanner:GetGoal(), true));
    else
        GoldPlanner:ToggleDashboard();
    end
end

local function RegisterSlashCommands()
    SLASH_GOLDPLANNER1 = GoldPlanner.STRINGS.SLASH_COMMAND;
    SLASH_GOLDPLANNER2 = GoldPlanner.STRINGS.SLASH_COMMAND_SHORT;

    SlashCmdList["GOLDPLANNER"] = HandleSlashCommand;
end

local function HandleEvents(self, event, ...)
    if event == EVENTS.ADDON_LOADED then
        local loadedAddonName = ...;

        if loadedAddonName ~= ADDON_NAME then
            return;
        end

        GoldPlanner:InitializeDatabase();
        GoldPlanner:BuildDashboard();
        GoldPlanner:BuildProgressBar();
        RegisterSlashCommands();
    elseif event == EVENTS.PLAYER_ENTERING_WORLD then
        GoldPlanner:UpdateCharacterCopper();
        GoldPlanner:UpdateWarbandCopper();
        GoldPlanner:UpdateDashboard();
        GoldPlanner:UpdateProgressBar();
    elseif event == EVENTS.PLAYER_MONEY then
        GoldPlanner:UpdateCharacterCopper();
        GoldPlanner:UpdateDashboard();
        GoldPlanner:UpdateProgressBar();
    elseif event == EVENTS.ACCOUNT_MONEY then
        GoldPlanner:UpdateWarbandCopper();
        GoldPlanner:UpdateDashboard();
        GoldPlanner:UpdateProgressBar();
    end
end

local eventFrame = CreateFrame("Frame");
eventFrame:RegisterEvent(EVENTS.ADDON_LOADED);
eventFrame:RegisterEvent(EVENTS.PLAYER_MONEY);
eventFrame:RegisterEvent(EVENTS.ACCOUNT_MONEY);
eventFrame:RegisterEvent(EVENTS.PLAYER_ENTERING_WORLD);
eventFrame:SetScript("OnEvent", HandleEvents);