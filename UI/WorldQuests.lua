local _, GoldPlanner = ...;

GoldPlanner.UI = GoldPlanner.UI or {};

local WorldQuests = {};
GoldPlanner.UI.WorldQuests = WorldQuests

local ROW_HEIGHT = GoldPlanner.UI.ActivityRow.HEIGHT;

local updateScheduled = false;

local function CreateQuestRow(parent)
    local WQ = GoldPlanner.Activities.WorldQuests;

    return GoldPlanner.UI.ActivityRow.Create(parent, {
        isTracked = function(questID)
            return WQ:IsTracked(questID);
        end,
        track = function(questID)
            WQ:Track(questID);
        end,
        untrack = function(questID)
            WQ:Untrack(questID);
        end,
        tooltip = function(tooltip, _, isTracked)
            tooltip:SetText(isTracked and "Click to untrack" or "Click to track");
        end,
    });
end

function WorldQuests:Build(parent)
    if self.built then
        return;
    end

    local title = parent:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge");
    title:SetPoint("TOPLEFT", 0, 0);
    title:SetText("World Quest Gold");

    local refreshButton = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate");
    refreshButton:SetSize(80, 22);
    refreshButton:SetText("Refresh");
    refreshButton:SetPoint("TOPRIGHT", 0, 4);
    refreshButton:SetScript("OnClick", function()
        self:RefreshWorldQuestGold();
    end);

    local totalText = parent:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge");
    totalText:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -10);
    totalText:SetText("Total Gold Available: " .. GetMoneyString(0, true));

    local columnHeaderGold = parent:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall");
    columnHeaderGold:SetPoint("TOPLEFT", totalText, "BOTTOMLEFT", 0, -14);
    columnHeaderGold:SetWidth(100);
    columnHeaderGold:SetJustifyH("LEFT");
    columnHeaderGold:SetText("Gold");

    local columnHeaderTitle = parent:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall");
    columnHeaderTitle:SetPoint("TOPLEFT", columnHeaderGold, "TOPRIGHT", 8, 0);
    columnHeaderTitle:SetText("Quest (Zone)");

    local scrollFrame = CreateFrame("ScrollFrame", nil, parent, "UIPanelScrollFrameTemplate");
    scrollFrame:SetPoint("TOPLEFT", columnHeaderGold, "BOTTOMLEFT", 0, -6);
    scrollFrame:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", -28, 0);

    local scrollChild = CreateFrame("Frame", nil, scrollFrame);
    scrollChild:SetSize(1, 1);
    scrollFrame:SetScrollChild(scrollChild);

    self.totalText = totalText;
    self.scrollFrame = scrollFrame;
    self.scrollChild = scrollChild;
    self.rows = {};

    EventRegistry:RegisterFrameEventAndCallback(
        GoldPlanner.EVENTS.QUEST_LOG_UPDATE,
        self.OnQuestLogUpdate,
        self);

    self.built = true;

    self:Update();
end

function WorldQuests:Update()
    if not self.built then
        return;
    end

    local WQ = GoldPlanner.Activities.WorldQuests;

    local scrollChild = self.scrollChild;
    local rows = self.rows;
    local quests = {};

    for _, quest in pairs(WQ:Get()) do
        if (quest.gold or 0) > 0 then
            quests[#quests + 1] = quest;
        end
    end

    table.sort(quests, function(a, b)
        return a.zoneID > b.zoneID;
    end);

    self.totalText:SetText("Total Gold Available: " .. GetMoneyString(WQ:GetTotalGold(), true));

    for index, quest in ipairs(quests) do
        local row = rows[index];

        if not row then
            row = CreateQuestRow(scrollChild);
            rows[index] = row;
        end

        row:ClearAllPoints();
        row:SetPoint("TOPLEFT", scrollChild, "TOPLEFT", 0, -(index - 1) * ROW_HEIGHT);
        row:SetPoint("RIGHT", scrollChild, "RIGHT", 0, 0);

        local zoneName = quest.zoneName and quest.zoneName or "Unknown";

        row:SetActivity(
            quest.questID,
            GetMoneyString(quest.gold, true),
            string.format("%s (%s)", quest.title or "Unknown Quest", zoneName));
        row:Show();
    end

    for index = #quests + 1, #rows do
        rows[index]:Hide();
    end

    scrollChild:SetWidth(math.max(1, self.scrollFrame:GetWidth()));
    scrollChild:SetHeight(math.max(1, #quests * ROW_HEIGHT));
end

function WorldQuests:RefreshWorldQuestGold()
    GoldPlanner.Activities.WorldQuests:ScanAll();
    self:Update();
end

function WorldQuests:RequestUpdate()
    if updateScheduled then
        return;
    end

    updateScheduled = true;

    C_Timer.After(0, function()
        updateScheduled = false;
        self:Update();
    end);
end

function WorldQuests:OnQuestLogUpdate()
    if GoldPlanner.Activities.WorldQuests:ResolvePendingRewards() then
        self:RequestUpdate();
    end
end
