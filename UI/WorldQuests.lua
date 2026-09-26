local _, GoldPlanner = ...;

GoldPlanner.UI = GoldPlanner.UI or {};

local WorldQuests = {};
GoldPlanner.UI.WorldQuests = WorldQuests

local ROW_HEIGHT = 18;

local function CreateQuestRow(parent)
    local row = CreateFrame("Frame", nil, parent);
    row:SetHeight(ROW_HEIGHT);

    row.gold = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall");
    row.gold:SetPoint("LEFT", 0, 0);
    row.gold:SetWidth(80);
    row.gold:SetJustifyH("LEFT");

    row.title = row:CreateFontString(nil, "OVERLAY", "GameFontWhiteSmall");
    row.title:SetPoint("LEFT", row.gold, "RIGHT", 8, 0);
    row.title:SetPoint("RIGHT", row, "RIGHT", 0, 0);
    row.title:SetJustifyH("LEFT");
    row.title:SetWordWrap(false);

    return row;
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
        GoldPlanner:RefreshWorldQuestGold();
    end);

    local totalText = parent:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge");
    totalText:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -10);
    totalText:SetText("Total Gold Available: " .. GetMoneyString(0, true));

    local columnHeader = parent:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall");
    columnHeader:SetPoint("TOPLEFT", totalText, "BOTTOMLEFT", 0, -14);
    columnHeader:SetText("Gold" .. string.rep(" ", 12) .. "Quest (Zone)");

    local scrollFrame = CreateFrame("ScrollFrame", nil, parent, "UIPanelScrollFrameTemplate");
    scrollFrame:SetPoint("TOPLEFT", columnHeader, "BOTTOMLEFT", 0, -6);
    scrollFrame:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", -28, 0);

    local scrollChild = CreateFrame("Frame", nil, scrollFrame);
    scrollChild:SetSize(1, 1);
    scrollFrame:SetScrollChild(scrollChild);

    self.totalText = totalText;
    self.scrollFrame = scrollFrame;
    self.scrollChild = scrollChild;
    self.rows = {};

    self.built = true;

    self:Update();
end

function WorldQuests:Update()
    if not self.built then
        return;
    end

    local scrollChild = self.scrollChild;
    local rows = self.rows;
    local quests = {};

    for _, quest in pairs(GoldPlanner.Runtime.WorldQuests) do
        if (quest.gold or 0) > 0 then
            quests[#quests + 1] = quest;
        end
    end

    table.sort(quests, function(a, b)
        return a.gold > b.gold;
    end);

    self.totalText:SetText("Total Gold Available: " .. GetMoneyString(GoldPlanner:GetTotalWorldQuestGold(), true));

    for index, quest in ipairs(quests) do
        local row = rows[index];

        if not row then
            row = CreateQuestRow(scrollChild);
            rows[index] = row;
        end

        row:ClearAllPoints();
        row:SetPoint("TOPLEFT", scrollChild, "TOPLEFT", 0, -(index - 1) * ROW_HEIGHT);
        row:SetPoint("RIGHT", scrollChild, "RIGHT", 0, 0);

        local mapInfo = C_Map.GetMapInfo(quest.mapID);
        local zoneName = mapInfo and mapInfo.name or "Unknown";

        row.gold:SetText(GetMoneyString(quest.gold, true));
        row.title:SetText(string.format("%s (%s)", quest.title or "Unknown Quest", zoneName));
        row:Show();
    end

    for index = #quests + 1, #rows do
        rows[index]:Hide();
    end

    scrollChild:SetWidth(math.max(1, self.scrollFrame:GetWidth()));
    scrollChild:SetHeight(math.max(1, #quests * ROW_HEIGHT));
end
