local _, GoldPlanner = ...;

local function GetWorldQuestInfo(questID, mapID)
    local title = C_TaskQuest.GetQuestInfoByQuestID(questID);
    local x, y = C_TaskQuest.GetQuestLocation(questID, mapID);
    local timeLeft = C_TaskQuest.GetQuestTimeLeftMinutes(questID);
    local money = GetQuestLogRewardMoney(questID);
    local currencies = {};

    for _, currency in C_QuestLog.GetQuestRewardCurrencies(questID) do
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

function GoldPlanner:GetWorldQuestsOnMap(mapID)
    local taskPOIs = C_TaskQuest.GetQuestsOnMap(mapID) or {};
    local quests = {};
    
    for _, taskPOI in ipairs(taskPOIs) do
        local questID = taskPOI.questID;
        
        if C_QuestLog.IsWorldQuest(questID) then
            quests[#quests + 1] = GetWorldQuestInfo(questID, mapID);
        end
    end
    
    return quests;
end

function GoldPlanner:RequestWorldQuestRewardData(questID)
    C_TaskQuest.RequestPreloadRewardData(questID);
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