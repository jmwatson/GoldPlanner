local _, GoldPlanner = ...;

local sformat = string.format;

function GoldPlanner:BuildDashboard()
    if self.dashboard then
        return;
    end

    local dashboard = CreateFrame("Frame", "GoldPlannerDashboard", UIParent, "BasicFrameTemplateWithInset");
    tinsert(UISpecialFrames, "GoldPlannerDashboard");

    dashboard:SetSize(500, 350);
    dashboard:SetPoint("CENTER");
    dashboard:SetMovable(true);
    dashboard:EnableMouse(true);
    dashboard:RegisterForDrag("LeftButton");

    dashboard:SetScript("OnDragStart", function(self)
        self:StartMoving();
    end);

    dashboard:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing();
    end);

    dashboard:Hide();

    local title = dashboard:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge");
    title:SetPoint("TOP", 0, -5);
    title:SetText(self.STRINGS.ADDON_TITLE);

    local characterGold = dashboard:CreateFontString(nil, "OVERLAY", "GameFontNormal");
    characterGold:SetPoint("TOPLEFT", 20, -50);

    local warbandGold = dashboard:CreateFontString(nil, "OVERLAY", "GameFontNormal");
    warbandGold:SetPoint("TOPLEFT", 20, -80);

    local totalGold = dashboard:CreateFontString(nil, "OVERLAY", "GameFontNormal");
    totalGold:SetPoint("TOPLEFT", 20, -110);

    local goal = dashboard:CreateFontString(nil, "OVERLAY", "GameFontNormal");
    goal:SetPoint("TOPLEFT", 20, -155);

    local remaining = dashboard:CreateFontString(nil, "OVERLAY", "GameFontNormal");
    remaining:SetPoint("TOPLEFT", 20, -185);

    local progress = dashboard:CreateFontString(nil, "OVERLAY", "GameFontNormal");
    progress:SetPoint("TOPLEFT", 20, -215);

    local rate = dashboard:CreateFontString(nil, "OVERLAY", "GameFontNormal");
    rate:SetPoint("TOPLEFT", 20, -250);

    local timeToGoal = dashboard:CreateFontString(nil, "OVERLAY", "GameFontNormal");
    timeToGoal:SetPoint("TOPLEFT", 20, -280);

    GoldPlanner:BuildActivities(dashboard);

    dashboard.characterGold = characterGold;
    dashboard.warbandGold = warbandGold;
    dashboard.totalGold = totalGold;
    dashboard.goal = goal;
    dashboard.remaining = remaining;
    dashboard.progress = progress;
    dashboard.rate = rate;
    dashboard.timeToGoal = timeToGoal;

    self.dashboard = dashboard;

    self:UpdateDashboard();
end

function GoldPlanner:UpdateDashboard()
    if not self.dashboard then
        return;
    end

    local dashboard = self.dashboard;
    dashboard.characterGold:SetText("Character: " .. GetMoneyString(self:GetCharacter().copper, true));
    dashboard.warbandGold:SetText("Warband: " .. GetMoneyString(self:GetWarband().copper, true));
    dashboard.totalGold:SetText("Total: " .. GetMoneyString(self:GetTotalCopper(), true));

    local goal = self:GetGoal();

    if goal <= 0 then
        dashboard.goal:SetText(self.STRINGS.GOAL .. ": " .. self.STRINGS.NO_GOAL);
        dashboard.remaining:SetText(self.STRINGS.EMPTY_STRING);
        dashboard.progress:SetText(self.STRINGS.EMPTY_STRING);
        dashboard.timeToGoal:SetText(sformat("%s: %s", self.STRINGS.TIME_TO_GOAL, self.STRINGS.NO_GOAL));
    else
        local timeToGoal = self:GetTimeToGoalDisplay();
        dashboard.goal:SetText(sformat("%s: %s", self.STRINGS.GOAL, GetMoneyString(goal, true)));
        dashboard.remaining:SetText(sformat("%s: %s", self.STRINGS.REMAINING, GetMoneyString(self:GetGoalRemaining(), true)));
        dashboard.progress:SetText(sformat("%s: %s", self.STRINGS.PROGRESS, sformat("%.1f%%", self:GetGoalProgress() * 100)));
        dashboard.timeToGoal:SetText(timeToGoal and
            sformat("%s: %s", self.STRINGS.TIME_TO_GOAL, timeToGoal) or
            sformat("%s: %s", self.STRINGS.TIME_TO_GOAL, self.STRINGS.UNAVAILABLE));
    end

    local rateDisplay = self:GetMoneyRateDisplay();
    dashboard.rate:SetText(rateDisplay and
        sformat("%s: %s/hour", self.STRINGS.RATE, rateDisplay) or
        sformat("%s: %s", self.STRINGS.RATE, self.STRINGS.NOT_ENOUGH_DATA));
end

function GoldPlanner:ToggleDashboard()
    if self.dashboard:IsShown() then
        self.dashboard:Hide();
    else
        self:UpdateDashboard();
        self.dashboard:Show();
    end
end
