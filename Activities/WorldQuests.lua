local _, GoldPlanner = ...;

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

function GoldPlanner:PrintMapChain()
    local mapID = C_Map.GetBestMapForUnit("player");

    if not mapID then
        self:Log("Could not determine current map.");
        return;
    end

    self:Log("Map chain for current location:");

    while mapID do
        local info = C_Map.GetMapInfo(mapID);

        if not info then
            break;
        end

        self:Log(string.format("  %d: %s (mapType %d)", mapID, info.name, info.mapType));
        mapID = info.parentMapID;
    end
end

function GoldPlanner:GetCurrentExpansionMaps()
    local seen = {};
    local zoneMaps = {};

    for _, continentMapID in ipairs(self.EXPANSION_CONTINENTS) do
        CollectZoneMaps(continentMapID, seen, zoneMaps);
    end

    return zoneMaps;
end

function GoldPlanner:GetWorldQuestsOnMap(mapID)
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

function GoldPlanner:DebugMapQuests(mapID)
    local raw = C_TaskQuest.GetQuestsOnMap(mapID) or {};

    self:Log(string.format("Map %d: C_TaskQuest.GetQuestsOnMap returned %d entries", mapID, #raw));

    for _, questInfo in ipairs(raw) do
        self:Log("",
            "questID", questInfo.questID,
            "tagType", tostring(questInfo.questTagType),
            "isWorldQuest", tostring(C_QuestLog.IsWorldQuest(questInfo.questID)),
            "title", tostring(C_TaskQuest.GetQuestInfoByQuestID(questInfo.questID))
        );
    end
end

function GoldPlanner:RequestWorldQuestRewardData(questID)
    C_TaskQuest.RequestPreloadRewardData(questID);
end

function GoldPlanner:GetWorldQuests()
    return self.Runtime.WorldQuests;
end

function GoldPlanner:ClearWorldQuests()
    wipe(self.Runtime.WorldQuests);
end

function GoldPlanner:ScanWorldQuests(mapID)
    local quests = self:GetWorldQuestsOnMap(mapID);

    for _, quest in ipairs(quests) do
        self.Runtime.WorldQuests[quest.questID] = quest;
        self.Runtime.PendingRewardData[quest.questID] = true;
        self:RequestWorldQuestRewardData(quest.questID);
    end

    return quests;
end

function GoldPlanner:ScanAllWorldQuests()
    local zoneMaps = self:GetCurrentExpansionMaps();

    if #zoneMaps == 0 then
        self:Log("No expansion zones configured. Set GoldPlanner.EXPANSION_CONTINENTS in Constants.lua (use /gp maps to find the mapID).");
        return self.Runtime.WorldQuests;
    end

    self:ClearWorldQuests();

    local totalQuests = 0;

    for _, mapID in ipairs(zoneMaps) do
        local quests = self:ScanWorldQuests(mapID);
        totalQuests = totalQuests + #quests;
    end

    self:Log(string.format("Scanned %d zones, found %d world quests.", #zoneMaps, totalQuests));

    return self.Runtime.WorldQuests;
end

function GoldPlanner:GetTotalWorldQuestGold()
    local total = 0;

    for _, quest in pairs(self.Runtime.WorldQuests) do
        total = total + (quest.gold or 0);
    end

    return total;
end

function GoldPlanner:GetPendingRewardCount()
    local count = 0;

    for _ in pairs(self.Runtime.PendingRewardData) do
        count = count + 1;
    end

    return count;
end

function GoldPlanner:TrackWorldQuest(questID)
    C_QuestLog.AddWorldQuestWatch(questID);
    C_SuperTrack.SetSuperTrackedQuestID(questID);
end

function GoldPlanner:UntrackWorldQuest(questID)
    C_QuestLog.RemoveWorldQuestWatch(questID);
end

function GoldPlanner:HandleWorldQuestRewardData(questID)
    if not HaveQuestRewardData(questID) then
        return false;
    end

    local quest = self.Runtime.WorldQuests[questID];

    if not quest then
        return false;
    end

    quest.gold = GetQuestLogRewardMoney(questID);
    quest.currencies = C_QuestLog.GetQuestRewardCurrencies(questID);

    return true;
end
