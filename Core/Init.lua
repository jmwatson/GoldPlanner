local ADDON_NAME, GoldPlanner = ...;
local EVENTS = GoldPlanner.EVENTS;

GoldPlanner.name = ADDON_NAME;
GoldPlanner.version = C_AddOns.GetAddOnMetadata(ADDON_NAME, "Version");

local SECONDS_PER_DAY = 86400;

local function HandleBarCommand(value)
    local subcommand, rest = value:match("^(%S+)%s*(.*)$");
    local ProgressBar = GoldPlanner.UI.ProgressBar;
 
    if subcommand == "lock" then
        ProgressBar:SetLocked(true);
        GoldPlanner:Log("Progress bar locked.");
    elseif subcommand == "unlock" then
        ProgressBar:SetLocked(false);
        GoldPlanner:Log("Progress bar unlocked.");
    elseif subcommand == "size" then
        local width, height = rest:match("^(%d+)%s+(%d+)$");
        width, height = tonumber(width), tonumber(height);
 
        if not width or not height then
            GoldPlanner:Log("Usage: /gp bar size <width> <height>");
            return;
        end
 
        ProgressBar:SetSize(width, height);
        GoldPlanner:Log(string.format("Progress bar resized to %dx%d.", width, height));
    elseif subcommand == "color" then
        local r, g, b = rest:match("^([%d.]+)%s+([%d.]+)%s+([%d.]+)$");
        r, g, b = tonumber(r), tonumber(g), tonumber(b);
 
        if not r or not g or not b then
            GoldPlanner:Log("Usage: /gp bar color <r> <g> <b> (each 0-1)");
            return;
        end
 
        ProgressBar:SetColor({r, g, b});
        GoldPlanner:Log("Progress bar color updated.");
    elseif subcommand == "bordercolor" then
        local r, g, b = rest:match("^([%d.]+)%s+([%d.]+)%s+([%d.]+)$");
        r, g, b = tonumber(r), tonumber(g), tonumber(b);
 
        if not r or not g or not b then
            GoldPlanner:Log("Usage: /gp bar bordercolor <r> <g> <b> (each 0-1)");
            return;
        end
 
        ProgressBar:SetBorderColor({r, g, b});
        GoldPlanner:Log("Progress bar border color updated.");
    elseif subcommand == "reset" then
        ProgressBar:Reset();
        ProgressBar:ApplySettings();
        GoldPlanner:Log("Progress bar reset to defaults.");
    elseif subcommand == "show" then
        ProgressBar:Show(true);
    elseif subcommand == "hide" then
        ProgressBar:Show(false);
    else
        GoldPlanner:Log("Usage: /gp bar <lock|unlock|size|color|bordercolor|show|hide|reset>");
    end
end

local wqUpdateScheduled = false;

local function ScheduleWorldQuestPanelUpdate()
    if wqUpdateScheduled then
        return;
    end

    wqUpdateScheduled = true;

    C_Timer.After(0, function()
        wqUpdateScheduled = false;
        GoldPlanner.UI.WorldQuests:Update();
    end);
end

function GoldPlanner:RefreshWorldQuestGold()
    self:ScanAllWorldQuests();
    GoldPlanner.UI.WorldQuests:Update();
end

local function HandleSlashCommand(parameters)
    local command, value = parameters:match("^(%S+)%s*(.*)$");
    local usage = "Usage: /gp goal <gold amount> [days]";

    if command == "goal" then
        local amount, days = value:match("^(%S+)%s*(%S*)$");
        local gold = tonumber(amount);
        local days = tonumber(days);
        local Goal = GoldPlanner.Data.Goal;

        if not gold or gold <= 0 then
            GoldPlanner:Log(usage);
            return;
        end

        if days and days > 0 then
            Goal:SetDeadline(time() + days * SECONDS_PER_DAY);
        end

        Goal:Set(gold * 10000);
        GoldPlanner.UI.Overview:Update();
        GoldPlanner.UI.ProgressBar:Update();

        GoldPlanner:Log("Goal set to", GetMoneyString(Goal:Get(), true));
    elseif command == "bar" then
        HandleBarCommand(value);
    elseif command == "settings" then
        Settings.OpenToCategory(GoldPlanner.UI.Settings.category:GetID());
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
        GoldPlanner.UI.Dashboard:Toggle();
    end
end

local function RegisterSlashCommands()
    SLASH_GOLDPLANNER1 = GoldPlanner.STRINGS.SLASH_COMMAND;
    SLASH_GOLDPLANNER2 = GoldPlanner.STRINGS.SLASH_COMMAND_SHORT;

    SlashCmdList["GOLDPLANNER"] = HandleSlashCommand;
end

local function HandleEvents(self, event, ...)
    local Overview = GoldPlanner.UI.Overview;
    local StatsBox = GoldPlanner.UI.StatsBox;
    local ProgressBar = GoldPlanner.UI.ProgressBar;
    local Gold = GoldPlanner.Data.Gold;

    if event == EVENTS.ADDON_LOADED then
        local loadedAddonName = ...;

        if loadedAddonName ~= ADDON_NAME then
            return;
        end

        GoldPlanner:InitializeDatabase();
        GoldPlanner:CompactAllHistory();
        GoldPlanner.UI.Settings:Build();
        GoldPlanner.UI.Dashboard:Build();
        ProgressBar:Build();
        StatsBox:Build();
        RegisterSlashCommands();
    elseif event == EVENTS.PLAYER_ENTERING_WORLD then
        Gold:UpdateCharacterCopper();
        Gold:UpdateWarbandCopper();
        Overview:Update();
        ProgressBar:Update();
        StatsBox:Update();
    elseif event == EVENTS.PLAYER_MONEY then
        Gold:UpdateCharacterCopper();
        Overview:Update();
        ProgressBar:Update();
        StatsBox:Update();
    elseif event == EVENTS.ACCOUNT_MONEY then
        Gold:UpdateWarbandCopper();
        Overview:Update();
        ProgressBar:Update();
        StatsBox:Update();
    elseif event == EVENTS.QUEST_LOG_UPDATE then
        local pending = GoldPlanner.Runtime.PendingRewardData;
        local resolvedAny = false;

        for questID in pairs(pending) do
            if HaveQuestRewardData(questID) then
                GoldPlanner:HandleWorldQuestRewardData(questID);
                pending[questID] = nil;
                resolvedAny = true;
            end
        end

        if resolvedAny then
            ScheduleWorldQuestPanelUpdate();
        end
    end
end

local eventFrame = CreateFrame("Frame");
eventFrame:RegisterEvent(EVENTS.ADDON_LOADED);
eventFrame:RegisterEvent(EVENTS.PLAYER_MONEY);
eventFrame:RegisterEvent(EVENTS.ACCOUNT_MONEY);
eventFrame:RegisterEvent(EVENTS.PLAYER_ENTERING_WORLD);
eventFrame:RegisterEvent(EVENTS.QUEST_LOG_UPDATE);
eventFrame:SetScript("OnEvent", HandleEvents);