local _, GoldPlanner = ...;

GoldPlanner.UI = GoldPlanner.UI or {};

local StatsBox = {};

GoldPlanner.UI.StatsBox = StatsBox;

function StatsBox:Build(parent)
    if self.statsBox then
        return;
    end

    local settings = GoldPlanner.db.settings.statsBox;

    local frame = CreateFrame("Frame", "GoldPlannerStatsBox", parent or UIParent);
    frame:SetPoint(settings.point, parent or UIParent, settings.point, settings.x, settings.y);
    frame:SetMovable(true);
    frame:SetClampedToScreen(true);
    frame:EnableMouse(not settings.locked);
    frame:RegisterForDrag("RightButton");

    frame:SetScript("OnDragStart", function(self)
        self:StartMoving();
    end);

    frame:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing();
        StatsBox:SavePosition();
    end);

    frame:SetShown(settings.show);

    frame.bg = frame:CreateTexture(nil, "BACKGROUND");
    frame.bg:SetPoint("TOPLEFT", frame, "TOPLEFT", -settings.padding, settings.padding);
    frame.bg:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", settings.padding, -settings.padding);
    frame.bg:SetColorTexture(0, 0, 0, 0.3);

    frame.rate = frame:CreateFontString(nil, "OVERLAY", "GameFontWhite");
    frame.rate:SetPoint("TOP", frame, "TOP");

    frame.timeToGoal = frame:CreateFontString(nil, "OVERLAY", "GameFontWhite");
    frame.timeToGoal:SetPoint("TOP", frame.rate, "BOTTOM");

    frame.dailyGoal = frame:CreateFontString(nil, "OVERLAY", "GameFontWhite");
    frame.dailyGoal:SetPoint("TOP", frame.timeToGoal, "BOTTOM");

    self.statsBox = frame;

    self:Update();
end

function StatsBox:Update()
    if not self.statsBox then
        return;
    end

    local GP = GoldPlanner;
    local sformat = string.format;
    local frame = self.statsBox;
    local goal = GP.Data.Goal:Get();

    if goal <= 0 then
        frame.timeToGoal:SetText(sformat("%s: %s", GoldPlanner.STRINGS.TIME_TO_GOAL, GoldPlanner.STRINGS.NO_GOAL));
    else
        local timeToGoal = GoldPlanner:GetTimeToGoalDisplay();
        frame.timeToGoal:SetText(timeToGoal and
            sformat("%s: %s", GoldPlanner.STRINGS.TIME_TO_GOAL, timeToGoal) or
            sformat("%s: %s", GoldPlanner.STRINGS.TIME_TO_GOAL, GoldPlanner.STRINGS.UNAVAILABLE));

        local dailyGoalDisplay = GoldPlanner:GetDailyGoalDisplay();
        frame.dailyGoal:SetText(dailyGoalDisplay and
            sformat("%s: %s", GoldPlanner.STRINGS.DAILY_GOAL, dailyGoalDisplay) or
            sformat("%s: %s", GoldPlanner.STRINGS.DAILY_GOAL, GoldPlanner.STRINGS.NO_DEADLINE));
    end

    local rateDisplay = GoldPlanner:GetMoneyRateDisplay(self.TrimGold);
    frame.rate:SetText(rateDisplay and
        sformat("%s: %s/hour", GoldPlanner.STRINGS.RATE, rateDisplay) or
        sformat("%s: %s", GoldPlanner.STRINGS.RATE, GoldPlanner.STRINGS.NOT_ENOUGH_DATA));

    local width = math.max(frame.rate:GetStringWidth(), frame.timeToGoal:GetStringWidth(), frame.dailyGoal:GetStringWidth());
    local height = frame.rate:GetStringHeight() + frame.timeToGoal:GetStringHeight() + frame.dailyGoal:GetStringHeight();
    frame:SetSize(width, height);
end

function StatsBox:ApplySettings()
    local frame = self.statsBox;

    if frame then
        local settings = GoldPlanner.db.settings.statsBox;

        frame:ClearAllPoints();
        frame:SetPoint(settings.point, UIParent, settings.point, settings.x, settings.y);
        frame:EnableMouse(not settings.locked);
        frame:SetShown(settings.show);
        frame.bg:SetPoint("TOPLEFT", frame, "TOPLEFT", -settings.padding, settings.padding);
        frame.bg:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", settings.padding, -settings.padding);

        self:Update();
    end
end

function StatsBox:SetLocked(lock)
    if self.statsBox then
        GoldPlanner.db.settings.statsBox.locked = lock;
        self.statsBox:EnableMouse(not lock);
    end
end

function StatsBox:Show(show)
    if self.statsBox then
        GoldPlanner.db.settings.statsBox.show = show;
        self.statsBox:SetShown(show);
    end
end

function StatsBox:SetPadding(value)
    if self.statsBox then
        GoldPlanner.db.settings.statsBox.padding = value;
        self.statsBox.bg:SetPoint("TOPLEFT", self.statsBox, "TOPLEFT", -value, value);
        self.statsBox.bg:SetPoint("BOTTOMRIGHT", self.statsBox, "BOTTOMRIGHT", value, -value);
    end
end

function StatsBox:SavePosition()
    local frame = self.statsBox;

    if frame then
        local point, _, _, x, y = frame:GetPoint();
        local settings = GoldPlanner.db.settings.statsBox;

        settings.point = point;
        settings.x = x;
        settings.y = y;
    end
end