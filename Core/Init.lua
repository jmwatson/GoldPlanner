local ADDON_NAME, GoldPlanner = ...;
local EVENTS = GoldPlanner.EVENTS;

GoldPlanner.name = ADDON_NAME;
GoldPlanner.version = C_AddOns.GetAddOnMetadata(ADDON_NAME, "Version");

local Log = GoldPlanner.Utils.Log;

local SECONDS_PER_DAY = 86400;

local function HandleBarCommand(value)
    local subcommand, rest = value:match("^(%S+)%s*(.*)$");
    local ProgressBar = GoldPlanner.UI.ProgressBar;
 
    if subcommand == "lock" then
        ProgressBar:SetLocked(true);
        Log("Progress bar locked.");
    elseif subcommand == "unlock" then
        ProgressBar:SetLocked(false);
        Log("Progress bar unlocked.");
    elseif subcommand == "size" then
        local width, height = rest:match("^(%d+)%s+(%d+)$");
        width, height = tonumber(width), tonumber(height);
 
        if not width or not height then
            Log("Usage: /gp bar size <width> <height>");
            return;
        end
 
        ProgressBar:SetSize(width, height);
        Log(string.format("Progress bar resized to %dx%d.", width, height));
    elseif subcommand == "color" then
        local r, g, b = rest:match("^([%d.]+)%s+([%d.]+)%s+([%d.]+)$");
        r, g, b = tonumber(r), tonumber(g), tonumber(b);
 
        if not r or not g or not b then
            Log("Usage: /gp bar color <r> <g> <b> (each 0-1)");
            return;
        end
 
        ProgressBar:SetColor({r, g, b});
        Log("Progress bar color updated.");
    elseif subcommand == "bordercolor" then
        local r, g, b = rest:match("^([%d.]+)%s+([%d.]+)%s+([%d.]+)$");
        r, g, b = tonumber(r), tonumber(g), tonumber(b);
 
        if not r or not g or not b then
            Log("Usage: /gp bar bordercolor <r> <g> <b> (each 0-1)");
            return;
        end
 
        ProgressBar:SetBorderColor({r, g, b});
        Log("Progress bar border color updated.");
    elseif subcommand == "reset" then
        ProgressBar:Reset();
        ProgressBar:ApplySettings();
        Log("Progress bar reset to defaults.");
    elseif subcommand == "show" then
        ProgressBar:Show(true);
    elseif subcommand == "hide" then
        ProgressBar:Show(false);
    else
        Log("Usage: /gp bar <lock|unlock|size|color|bordercolor|show|hide|reset>");
    end
end

local function HandleSlashCommand(parameters)
    local command, value = parameters:match("^(%S+)%s*(.*)$");
    local usage = "Usage: /gp goal <gold amount> [days]";

    local Dashboard = GoldPlanner.UI.Dashboard;

    if command == "goal" then
        local amount, days = value:match("^(%S+)%s*(%S*)$");
        local gold = tonumber(amount);
        local days = tonumber(days);
        local Goal = GoldPlanner.Data.Goal;

        if not gold or gold <= 0 then
            Log(usage);
            return;
        end

        if days and days > 0 then
            Goal:SetDeadline(time() + days * SECONDS_PER_DAY);
        end

        Goal:Set(gold * 10000);

        Log("Goal set to", GetMoneyString(Goal:Get(), true));
    elseif command == "bar" then
        HandleBarCommand(value);
    elseif command == "settings" then
        Settings.OpenToCategory(GoldPlanner.UI.Settings.category:GetID());
    elseif command == "maps" then
        GoldPlanner.Activities.WorldQuests:PrintMapChain();
    elseif command == "wq" then
        Dashboard:ShowWQ();
    elseif command == "wqdebug" then
        local mapID = tonumber(value);

        if not mapID then
            mapID = C_Map.GetBestMapForUnit("player");
        end

        GoldPlanner.Activities.WorldQuests:DebugMapQuests(mapID);
    elseif command == "overview" then
        Dashboard:ShowOverview();
    else
        Dashboard:Toggle();
    end
end

local function RegisterSlashCommands()
    SLASH_GOLDPLANNER1 = GoldPlanner.STRINGS.SLASH_COMMAND;
    SLASH_GOLDPLANNER2 = GoldPlanner.STRINGS.SLASH_COMMAND_SHORT;

    SlashCmdList["GOLDPLANNER"] = HandleSlashCommand;
end

local function OnAddonLoaded(_, loadedAddonName)
        if loadedAddonName ~= ADDON_NAME then
            return;
        end

        GoldPlanner.DB:InitializeDatabase();
        GoldPlanner.Data.History:CompactAll(
            GoldPlanner.Data.Account:GetCharacters(),
            GoldPlanner.Data.Account:GetWarband());
        GoldPlanner.Data.Gold:Initialize();
        RegisterSlashCommands();
end

EventRegistry:RegisterFrameEventAndCallback(EVENTS.ADDON_LOADED, OnAddonLoaded);
