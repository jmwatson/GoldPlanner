local ADDON_NAME, GoldPlanner = ...;
local EVENTS = GoldPlanner.EVENTS;

GoldPlanner.name = ADDON_NAME;
GoldPlanner.version = C_AddOns.GetAddOnMetadata(ADDON_NAME, "Version");

local SECONDS_PER_DAY = 86400;

local function HandleBarCommand(value)
    local subcommand, rest = value:match("^(%S+)%s*(.*)$");
 
    if subcommand == "lock" then
        GoldPlanner:SetProgressBarLocked(true);
        GoldPlanner:Log("Progress bar locked.");
    elseif subcommand == "unlock" then
        GoldPlanner:SetProgressBarLocked(false);
        GoldPlanner:Log("Progress bar unlocked.");
    elseif subcommand == "size" then
        local width, height = rest:match("^(%d+)%s+(%d+)$");
        width, height = tonumber(width), tonumber(height);
 
        if not width or not height then
            GoldPlanner:Log("Usage: /gp bar size <width> <height>");
            return;
        end
 
        GoldPlanner:SetProgressBarSize(width, height);
        GoldPlanner:Log(string.format("Progress bar resized to %dx%d.", width, height));
    elseif subcommand == "color" then
        local r, g, b = rest:match("^([%d.]+)%s+([%d.]+)%s+([%d.]+)$");
        r, g, b = tonumber(r), tonumber(g), tonumber(b);
 
        if not r or not g or not b then
            GoldPlanner:Log("Usage: /gp bar color <r> <g> <b> (each 0-1)");
            return;
        end
 
        GoldPlanner:SetProgressBarColor({r, g, b});
        GoldPlanner:Log("Progress bar color updated.");
    elseif subcommand == "bordercolor" then
        local r, g, b = rest:match("^([%d.]+)%s+([%d.]+)%s+([%d.]+)$");
        r, g, b = tonumber(r), tonumber(g), tonumber(b);
 
        if not r or not g or not b then
            GoldPlanner:Log("Usage: /gp bar bordercolor <r> <g> <b> (each 0-1)");
            return;
        end
 
        GoldPlanner:SetProgressBarBorderColor({r, g, b});
        GoldPlanner:Log("Progress bar border color updated.");
    elseif subcommand == "reset" then
        GoldPlanner:ResetProgressBar();
        GoldPlanner:ApplyProgressBarSettings();
        GoldPlanner:Log("Progress bar reset to defaults.");
    elseif subcommand == "show" then
        GoldPlanner:ShowProgressBar(true);
    elseif subcommand == "hide" then
        GoldPlanner:ShowProgressBar(false);
    else
        GoldPlanner:Log("Usage: /gp bar <lock|unlock|size|color|bordercolor|show|hide|reset>");
    end
end

local wqReportPending = false;

local function ReportWorldQuestTotal()
    if not wqReportPending then
        return;
    end

    wqReportPending = false;

    local pending = GoldPlanner:GetPendingRewardCount();
    local total = GetMoneyString(GoldPlanner:GetTotalWorldQuestGold(), true);

    if pending > 0 then
        GoldPlanner:Log(
            "Total world quest gold available:", total,
            "(still waiting on reward data for", pending, "quests)"
        );
    else
        GoldPlanner:Log("Total world quest gold available:", total);
    end

    GoldPlanner:UpdateActivitiesPanel();
end

function GoldPlanner:RefreshWorldQuestGold()
    self:ScanAllWorldQuests();
    self:UpdateActivitiesPanel();

    local pending = self:GetPendingRewardCount();

    if pending > 0 then
        self:Log("Scan complete, waiting on reward data for", pending, "quests...");
        wqReportPending = true;
        C_Timer.After(5,  ReportWorldQuestTotal);
    else
        wqReportPending = true;
        ReportWorldQuestTotal();
    end
end

local function HandleSlashCommand(parameters)
    local command, value = parameters:match("^(%S+)%s*(.*)$");
    local usage = "Usage: /gp goal <gold amount> [days]";

    if command == "goal" then
        local amount, days = value:match("^(%S+)%s*(%S*)$");
        local gold = tonumber(amount);
        local days = tonumber(days);

        if not gold or gold <= 0 then
            GoldPlanner:Log(usage);
            return;
        end

        if days and days > 0 then
            GoldPlanner:SetGoalDeadline(time() + days * SECONDS_PER_DAY);
        end

        GoldPlanner:SetGoal(gold * 10000);
        GoldPlanner:UpdateDashboard();
        GoldPlanner:UpdateProgressBar();

        GoldPlanner:Log("Goal set to", GetMoneyString(GoldPlanner:GetGoal(), true));
    elseif command == "bar" then
        HandleBarCommand(value);
    elseif command == "settings" then
        Settings.OpenToCategory(GoldPlanner.settingsCategory:GetID());
    elseif command == "maps" then
        GoldPlanner:PrintMapChain();
    elseif command == "wq" then
        GoldPlanner:RefreshWorldQuestGold();
    elseif command == "wqdebug" then
        local mapID = tonumber(value);

        if not mapID then
            mapID = C_Map.GetBestMapForUnit("player");
        end

        GoldPlanner:DebugMapQuests(mapID);
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
        GoldPlanner:CompactAllHistory();
        GoldPlanner:BuildSettings();
        GoldPlanner:BuildDashboard();
        GoldPlanner:BuildProgressBar();
        GoldPlanner:BuildStatsBox();
        RegisterSlashCommands();
    elseif event == EVENTS.PLAYER_ENTERING_WORLD then
        GoldPlanner:UpdateCharacterCopper();
        GoldPlanner:UpdateWarbandCopper();
        GoldPlanner:UpdateDashboard();
        GoldPlanner:UpdateProgressBar();
        GoldPlanner:UpdateStatsBox();
    elseif event == EVENTS.PLAYER_MONEY then
        GoldPlanner:UpdateCharacterCopper();
        GoldPlanner:UpdateDashboard();
        GoldPlanner:UpdateProgressBar();
        GoldPlanner:UpdateStatsBox();
    elseif event == EVENTS.ACCOUNT_MONEY then
        GoldPlanner:UpdateWarbandCopper();
        GoldPlanner:UpdateDashboard();
        GoldPlanner:UpdateProgressBar();
        GoldPlanner:UpdateStatsBox();
    elseif event == EVENTS.QUEST_DATA_LOAD_RESULT then
        local questID, success = ...;
        if success and GoldPlanner.Runtime.PendingRewardData[questID] then
            GoldPlanner.Runtime.PendingRewardData[questID] = nil;
            GoldPlanner:HandleWorldQuestRewardData(questID);
            
            if GoldPlanner:GetPendingRewardCount() == 0 then
                ReportWorldQuestTotal();
            end
        end
    end
end

local eventFrame = CreateFrame("Frame");
eventFrame:RegisterEvent(EVENTS.ADDON_LOADED);
eventFrame:RegisterEvent(EVENTS.PLAYER_MONEY);
eventFrame:RegisterEvent(EVENTS.ACCOUNT_MONEY);
eventFrame:RegisterEvent(EVENTS.PLAYER_ENTERING_WORLD);
eventFrame:RegisterEvent(EVENTS.QUEST_DATA_LOAD_RESULT);
eventFrame:SetScript("OnEvent", HandleEvents);