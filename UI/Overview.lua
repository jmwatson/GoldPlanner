local _, GoldPlanner = ...;

GoldPlanner.UI = GoldPlanner.UI or {};

local Overview = {};
GoldPlanner.UI.Overview = Overview;

function Overview:Build(parent)
    if self.built then
        return;
    end

    local goldText = parent:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge");
    goldText:SetPoint("TOPLEFT", 20, -40);
    goldText:SetText("Gold");

    local characterGold = parent:CreateFontString(nil, "OVERLAY", "GameFontWhite");
    characterGold:SetPoint("TOPLEFT", 20, -60);

    local warbandGold = parent:CreateFontString(nil, "OVERLAY", "GameFontWhite");
    warbandGold:SetPoint("TOPLEFT", 20, -80);

    local totalGold = parent:CreateFontString(nil, "OVERLAY", "GameFontWhite");
    totalGold:SetPoint("TOPLEFT", 20, -100);

    local goalText = parent:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge");
    goalText:SetPoint("TOPLEFT", 20, -130);
    goalText:SetText("Goal");

    local goal = parent:CreateFontString(nil, "OVERLAY", "GameFontWhite");
    goal:SetPoint("TOPLEFT", 20, -150);

    local remaining = parent:CreateFontString(nil, "OVERLAY", "GameFontWhite");
    remaining:SetPoint("TOPLEFT", 20, -170);

    local progressInset = 3;
    local barInset = 5;
    local progress = CreateFrame("StatusBar", nil, parent, "BackdropTemplate");
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

    local statsText = parent:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge");
    statsText:SetPoint("TOPLEFT", 20, -220);
    statsText:SetText("Statistics");

    local rate = parent:CreateFontString(nil, "OVERLAY", "GameFontWhite");
    rate:SetPoint("TOPLEFT", 20, -240);

    local timeToGoal = parent:CreateFontString(nil, "OVERLAY", "GameFontWhite");
    timeToGoal:SetPoint("TOPLEFT", 20, -260);

    local dailyGoal = parent:CreateFontString(nil, "OVERLAY", "GameFontWhite");
    dailyGoal:SetPoint("TOPLEFT", 20, -280);

    self.characterGold = characterGold;
    self.warbandGold = warbandGold;
    self.totalGold = totalGold;
    self.goal = goal;
    self.remaining = remaining;
    self.progress = progress;
    self.rate = rate;
    self.timeToGoal = timeToGoal;
    self.dailyGoal = dailyGoal;

    self.built = true;
end

function Overview:Update()
    if not self.built then
        return;
    end

    local GP = GoldPlanner;

    self.characterGold:SetText("Character: " .. GetMoneyString(GP:GetCharacter().copper, true));
    self.warbandGold:SetText("Warband: " .. GetMoneyString(GP:GetWarband().copper, true));
    self.totalGold:SetText("Total: " .. GetMoneyString(GP:GetTotalCopper(), true));

    local goal = GP:GetGoal();

    if goal <= 0 then
        self.goal:SetText(GP.STRINGS.GOAL .. ": " .. GP.STRINGS.NO_GOAL);
        self.remaining:SetText(GP.STRINGS.EMPTY_STRING);
        self.progress.bar:SetValue(0);
        self.progress.bar.text:SetText(GP.STRINGS.EMPTY_STRING);
        self.timeToGoal:SetText(string.format("%s: %s", GP.STRINGS.TIME_TO_GOAL, GP.STRINGS.NO_GOAL));
    else
        local timeToGoal = GP:GetTimeToGoalDisplay();
        local goalProgress = GP:GetGoalProgress();
        self.goal:SetText(string.format("%s: %s", GP.STRINGS.GOAL, GetMoneyString(goal, true)));
        self.remaining:SetText(string.format("%s: %s", GP.STRINGS.REMAINING, GetMoneyString(GP:GetGoalRemaining(), true)));
        self.progress.bar:SetValue(goalProgress);
        self.progress.bar.text:SetText(string.format("%.1f%%", goalProgress * 100));
        self.timeToGoal:SetText(timeToGoal and
            string.format("%s: %s", GP.STRINGS.TIME_TO_GOAL, timeToGoal) or
            string.format("%s: %s", GP.STRINGS.TIME_TO_GOAL, GP.STRINGS.UNAVAILABLE));
    end

    local rateDisplay = GP:GetMoneyRateDisplay();
    self.rate:SetText(rateDisplay and
        string.format("%s: %s/hour", GP.STRINGS.RATE, rateDisplay) or
        string.format("%s: %s", GP.STRINGS.RATE, GP.STRINGS.NOT_ENOUGH_DATA));

    local dailyGoalDisplay = GP:GetDailyGoalDisplay();
    self.dailyGoal:SetText(dailyGoalDisplay and
        string.format("%s: %s", GP.STRINGS.DAILY_GOAL, dailyGoalDisplay) or
        string.format("%s: %s", GP.STRINGS.DAILY_GOAL, GP.STRINGS.NO_DEADLINE));
end