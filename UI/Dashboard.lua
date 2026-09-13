local _, GoldPlanner = ...;

local sformat = string.format;

function GoldPlanner:BuildDashboard()
    if self.dashboard then
        return;
    end

    local dashboard = CreateFrame("Frame", "GoldPlannerDashboard", UIParent, "BasicFrameTemplateWithInset");
    tinsert(UISpecialFrames, "GoldPlannerDashboard");

    dashboard:SetSize(500, 500);
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

    local goldText = dashboard:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge");
    goldText:SetPoint("TOPLEFT", 20, -40);
    goldText:SetText("Gold");

    local characterGold = dashboard:CreateFontString(nil, "OVERLAY", "GameFontWhite");
    characterGold:SetPoint("TOPLEFT", 20, -60);

    local warbandGold = dashboard:CreateFontString(nil, "OVERLAY", "GameFontWhite");
    warbandGold:SetPoint("TOPLEFT", 20, -80);

    local totalGold = dashboard:CreateFontString(nil, "OVERLAY", "GameFontWhite");
    totalGold:SetPoint("TOPLEFT", 20, -100);

    local goalText = dashboard:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge");
    goalText:SetPoint("TOPLEFT", 20, -130);
    goalText:SetText("Goal");

    local goal = dashboard:CreateFontString(nil, "OVERLAY", "GameFontWhite");
    goal:SetPoint("TOPLEFT", 20, -150);

    local remaining = dashboard:CreateFontString(nil, "OVERLAY", "GameFontWhite");
    remaining:SetPoint("TOPLEFT", 20, -170);

    local progressInset = 3;
    local barInset = 5;
    local progress = CreateFrame("StatusBar", nil, dashboard, "BackdropTemplate");
    progress:SetPoint("TOPLEFT", 20, -190);
    progress:SetSize(300, 25);
    progress:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true,
        tileSize = 16,
        edgeSize = 12,
        insets = {
            left = progressInset,
            right = progressInset,
            top = progressInset,
            bottom = progressInset,
        },
    });
    progress.bar = CreateFrame("StatusBar", nil, progress);
    progress.bar:SetPoint("TOPLEFT", barInset, -barInset);
    progress.bar:SetPoint("BOTTOMRIGHT", -barInset, barInset);
    progress.bar:SetMinMaxValues(0, 1);

    local progressTexture = progress.bar:CreateTexture(nil, "ARTWORK");
    progressTexture:SetColorTexture(0.8, 0.55, 0);
    progress.bar:SetStatusBarTexture(progressTexture);

    progress.bar.text = progress.bar:CreateFontString(nil, "OVERLAY", "GameFontWhite");
    progress.bar.text:SetPoint("CENTER");

    local statsText = dashboard:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge");
    statsText:SetPoint("TOPLEFT", 20, -220);
    statsText:SetText("Statistics");

    local rate = dashboard:CreateFontString(nil, "OVERLAY", "GameFontWhite");
    rate:SetPoint("TOPLEFT", 20, -240);

    local timeToGoal = dashboard:CreateFontString(nil, "OVERLAY", "GameFontWhite");
    timeToGoal:SetPoint("TOPLEFT", 20, -260);

    local dailyGoal = dashboard:CreateFontString(nil, "OVERLAY", "GameFontWhite");
    dailyGoal:SetPoint("TOPLEFT", 20, -280);

    GoldPlanner:BuildActivities(dashboard);

    dashboard.characterGold = characterGold;
    dashboard.warbandGold = warbandGold;
    dashboard.totalGold = totalGold;
    dashboard.goal = goal;
    dashboard.remaining = remaining;
    dashboard.progress = progress;
    dashboard.rate = rate;
    dashboard.timeToGoal = timeToGoal;
    dashboard.dailyGoal = dailyGoal;

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
        dashboard.progress.bar:SetValue(0);
        dashboard.progress.bar.text:SetText(self.STRINGS.EMPTY_STRING);
        dashboard.timeToGoal:SetText(sformat("%s: %s", self.STRINGS.TIME_TO_GOAL, self.STRINGS.NO_GOAL));
    else
        local timeToGoal = self:GetTimeToGoalDisplay();
        local goalProgress = self:GetGoalProgress();
        dashboard.goal:SetText(sformat("%s: %s", self.STRINGS.GOAL, GetMoneyString(goal, true)));
        dashboard.remaining:SetText(sformat("%s: %s", self.STRINGS.REMAINING, GetMoneyString(self:GetGoalRemaining(), true)));
        dashboard.progress.bar:SetValue(goalProgress);
        dashboard.progress.bar.text:SetText(sformat("%.1f%%", goalProgress * 100));
        dashboard.timeToGoal:SetText(timeToGoal and
            sformat("%s: %s", self.STRINGS.TIME_TO_GOAL, timeToGoal) or
            sformat("%s: %s", self.STRINGS.TIME_TO_GOAL, self.STRINGS.UNAVAILABLE));
    end

    local rateDisplay = self:GetMoneyRateDisplay();
    dashboard.rate:SetText(rateDisplay and
        sformat("%s: %s/hour", self.STRINGS.RATE, rateDisplay) or
        sformat("%s: %s", self.STRINGS.RATE, self.STRINGS.NOT_ENOUGH_DATA));

    local dailyGoalDisplay = self:GetDailyGoalDisplay();
    dashboard.dailyGoal:SetText(dailyGoalDisplay and
        sformat("%s: %s", self.STRINGS.DAILY_GOAL, dailyGoalDisplay) or
        sformat("%s: %s", self.STRINGS.DAILY_GOAL, self.STRINGS.NO_DEADLINE));
end

function GoldPlanner:ToggleDashboard()
    if self.dashboard:IsShown() then
        self.dashboard:Hide();
    else
        self:UpdateDashboard();
        self.dashboard:Show();
    end
end
