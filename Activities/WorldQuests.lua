local _, GoldPlanner = ...;

GoldPlanner.Activities = GoldPlanner.Activities or {};

local WorldQuests = {};
GoldPlanner.Activities.WorldQuests = WorldQuests;

local function GetWorldQuestInfo(questID, mapID)
    local title = C_TaskQuest.GetQuestInfoByQuestID(questID);
    local x, y = C_TaskQuest.GetQuestLocation(questID, mapID);
    local timeLeft = C_TaskQuest.GetQuestTimeLeftMinutes(questID);
    local money = GetQuestLogRewardMoney(questID);
    local currencies = {};

    for _, currency in ipairs(C_QuestLog.GetQuestRewardCurrencies(questID) or {}) do
        currencies[#currencies + 1] = {
            name = currency.name,
            amount = currency.totalRewardAmount,
            currencyID = currency.currencyID,
        };
    end

    return {
        questID = questID,
        mapID = mapID,
        title = title,
        x = x,
        y = y,
        timeLeft = timeLeft,
        gold = money,
        currencies = currencies,
    };
end

local function CollectZoneMaps(mapID, seen, results)
    if seen[mapID] then
        return results;
    end

    seen[mapID] = true;

    local mapInfo = C_Map.GetMapInfo(mapID);

    if mapInfo and mapInfo.mapType == Enum.UIMapType.Zone then
        results[#results + 1] = mapID;
    end

    local children = C_Map.GetMapChildrenInfo(mapID) or {};

    for _, child in ipairs(children) do
        CollectZoneMaps(child.mapID, seen, results);
    end

    return results;
end

local function GetCurrentExpansionMaps()
    local seen = {};
    local zoneMaps = {};

    for _, continentMapID in ipairs(GoldPlanner.EXPANSION_CONTINENTS) do
        CollectZoneMaps(continentMapID, seen, zoneMaps);
    end

    return zoneMaps;
end

local function GetWorldQuestsOnMap(mapID)
    local questsOnMap = C_TaskQuest.GetQuestsOnMap(mapID) or {};
    local quests = {};

    for _, questInfo in ipairs(questsOnMap) do
        local questID = questInfo.questID;

        if C_QuestLog.IsWorldQuest(questID) then
            quests[#quests+1] = GetWorldQuestInfo(questID, mapID);
        end
    end

    return quests;
end

function WorldQuests:PrintMapChain()
    local mapID = C_Map.GetBestMapForUnit("player");

    if not mapID then
        GoldPlanner:Log("Could not determine current map.");
        return;
    end

    GoldPlanner:Log("Map chain for current location:");

    while mapID do
        local info = C_Map.GetMapInfo(mapID);

        if not info then
            break;
        end

        GoldPlanner:Log(string.format("  %d: %s (mapType %d)", mapID, info.name, info.mapType));
        mapID = info.parentMapID;
    end
end

function WorldQuests:DebugMapQuests(mapID)
    local raw = C_TaskQuest.GetQuestsOnMap(mapID) or {};

    GoldPlanner:Log(string.format("Map %d: C_TaskQuest.GetQuestsOnMap returned %d entries", mapID, #raw));

    for _, questInfo in ipairs(raw) do
        GoldPlanner:Log("",
            "questID", questInfo.questID,
            "tagType", tostring(questInfo.questTagType),
            "isWorldQuest", tostring(C_QuestLog.IsWorldQuest(questInfo.questID)),
            "title", tostring(C_TaskQuest.GetQuestInfoByQuestID(questInfo.questID))
        );
    end
end

function WorldQuests:Get()
    return GoldPlanner.Runtime.WorldQuests;
end

function WorldQuests:Clear()
    wipe(GoldPlanner.Runtime.WorldQuests);
    wipe(GoldPlanner.Runtime.PendingRewardData);
end

function WorldQuests:Scan(mapID)
    local quests = GetWorldQuestsOnMap(mapID);

    for _, quest in ipairs(quests) do
        GoldPlanner.Runtime.WorldQuests[quest.questID] = quest;
        GoldPlanner.Runtime.PendingRewardData[quest.questID] = true;
        C_TaskQuest.RequestPreloadRewardData(quest.questID);
    end

    return quests;
end

function WorldQuests:ScanAll()
    local zoneMaps = GetCurrentExpansionMaps();

    if #zoneMaps == 0 then
        GoldPlanner:Log("No expansion zones configured. Set GoldPlanner.EXPANSION_CONTINENTS in Constants.lua (use /gp maps to find the mapID).");
        return GoldPlanner.Runtime.WorldQuests;
    end

    self:Clear();

    local totalQuests = 0;

    for _, mapID in ipairs(zoneMaps) do
        local quests = self:Scan(mapID);
        totalQuests = totalQuests + #quests;
    end

    GoldPlanner:Log(string.format("Scanned %d zones, found %d world quests.", #zoneMaps, totalQuests));

    return GoldPlanner.Runtime.WorldQuests;
end

function WorldQuests:GetTotalGold()
    local total = 0;

    for _, quest in pairs(GoldPlanner.Runtime.WorldQuests) do
        total = total + (quest.gold or 0);
    end

    return total;
end

function WorldQuests:Track(questID)
    C_QuestLog.AddWorldQuestWatch(questID);
    C_SuperTrack.SetSuperTrackedQuestID(questID);
end

-- Not needed yet, but leaving in on the off chance we want this functionality later
function WorldQuests:Untrack(questID)
    C_QuestLog.RemoveWorldQuestWatch(questID);
end

function WorldQuests:HandleRewardData(questID)
    if not HaveQuestRewardData(questID) then
        return false;
    end

    local quest = GoldPlanner.Runtime.WorldQuests[questID];

    if not quest then
        return false;
    end

    quest.gold = GetQuestLogRewardMoney(questID);
    quest.currencies = C_QuestLog.GetQuestRewardCurrencies(questID);

    return true;
end
