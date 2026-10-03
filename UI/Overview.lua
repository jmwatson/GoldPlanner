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

    self:RegisterEvents();

    self.built = true;
end

function Overview:Update()
    if not self.built then
        return;
    end

    local GP = GoldPlanner;
    local Gold = GP.Data.Gold;
    local Goal = GP.Data.Goal;
    local Stats = GP.Data.Statistics;
    local Format = GP.UI.Format;

    local total = Gold:GetTotalCopper();

    self.characterGold:SetText("Character: " .. GetMoneyString(Gold:GetCharacterCopper(), true));
    self.warbandGold:SetText("Warband: " .. GetMoneyString(Gold:GetWarbandCopper(), true));
    self.totalGold:SetText("Total: " .. GetMoneyString(total, true));

    local goal = Goal:Get();

    if goal <= 0 then
        self.goal:SetText(GP.STRINGS.GOAL .. ": " .. GP.STRINGS.NO_GOAL);
        self.remaining:SetText(GP.STRINGS.EMPTY_STRING);
        self.progress.bar:SetValue(0);
        self.progress.bar.text:SetText(GP.STRINGS.EMPTY_STRING);
    else
        local goalProgress = Goal:GetProgress();
        self.goal:SetText(string.format("%s: %s", GP.STRINGS.GOAL, GetMoneyString(goal, true)));
        self.remaining:SetText(string.format("%s: %s", GP.STRINGS.REMAINING, GetMoneyString(Goal:GetRemaining(), true)));
        self.progress.bar:SetValue(goalProgress);
        self.progress.bar.text:SetText(string.format("%.1f%%", goalProgress * 100));
    end

    self.timeToGoal:SetText(Format.TimeToGoal(goal, Stats:GetTimeToGoal(total, goal)));
    self.rate:SetText(Format.Rate(Stats:GetHourlyRate(), false));
    self.dailyGoal:SetText(Format.DailyGoal(Stats:GetDailyGoalProgress(Goal:GetDaily(), total)));
end

function Overview:RegisterEvents()
    EventRegistry:RegisterCallback(
        GoldPlanner.EVENTS.HISTORY_TOTAL_UPDATED,
        self.Update,
        self
    );
end
