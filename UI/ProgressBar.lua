local _, GoldPlanner = ...;

function GoldPlanner:BuildProgressBar()
    if self.progressBar then
        return;
    end

    local frame = CreateFrame("Frame", "GoldPlannerProgressBar", UIParent);
    frame:SetSize(500, 20);
    frame:SetPoint("TOP");
    frame:SetMovable(true);
    frame:EnableMouse(true);
    frame:RegisterForDrag("RightButton");

    frame:SetScript("OnDragStart", function(self)
        self:StartMoving();
    end);

    frame:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing();
    end);

    frame:Show();

    local progress = CreateFrame("StatusBar", nil, frame);
    progress:SetPoint("TOPLEFT", 3, -3);
    progress:SetSize(494, 14);

    local background = progress:CreateTexture(nil, "BACKGROUND");
    background:SetAllPoints(progress);
    background:SetColorTexture(0, 0, 0, 0.7);

    local progressInset = 1;
    progress.bar = CreateFrame("StatusBar", nil, progress);
    progress.bar:SetPoint("TOPLEFT", progressInset, -progressInset);
    progress.bar:SetPoint("BOTTOMRIGHT", -progressInset, progressInset);
    progress.bar:SetMinMaxValues(0, 1);
    progress.bar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar");
    progress.bar:SetStatusBarColor(0.8, 0.55, 0);

    local TICK_COUNT = 10;
    local barWidth = 494;

    for i = 1, TICK_COUNT - 1 do
        local tick = progress.bar:CreateTexture(nil, "OVERLAY");
        tick:SetColorTexture(0, 0, 0, 0.5);
        tick:SetSize(2, 14);
        tick:SetPoint("LEFT", progress.bar, "LEFT", (barWidth / TICK_COUNT) * i, 0);
    end

    local BORDER_TEXTURE = "Interface\\PaperDollInfoFrame\\UI-Character-Skills-BarBorder";

    local borderLeft = frame:CreateTexture(nil, "OVERLAY");
    borderLeft:SetTexture(BORDER_TEXTURE);
    borderLeft:SetSize(9, 22);
    borderLeft:SetTexCoord(0.007843, 0.043137, 0.193548, 0.774193);
    borderLeft:SetPoint("LEFT", progress, "LEFT", -3, 0);

    local borderRight = frame:CreateTexture(nil, "OVERLAY");
    borderRight:SetTexture(BORDER_TEXTURE);
    borderRight:SetSize(9, 22);
    borderRight:SetTexCoord(0.043137, 0.007843, 0.193548, 0.774193);
    borderRight:SetPoint("RIGHT", progress, "RIGHT", 3, 0);

    local borderMid = frame:CreateTexture(nil, "OVERLAY");
    borderMid:SetTexture(BORDER_TEXTURE);
    borderMid:SetTexCoord(0.113726, 0.1490196, 0.193548, 0.774193);
    borderMid:SetPoint("TOPLEFT", borderLeft, "TOPRIGHT", 0, 0);
    borderMid:SetPoint("BOTTOMRIGHT", borderRight, "BOTTOMLEFT", 0, 0);

    progress.bar.text = progress.bar:CreateFontString(nil, "OVERLAY", "TextStatusBarText");
    progress.bar.text:SetPoint("CENTER");

    frame.progress = progress;

    self.progressBar = frame;

    self:UpdateProgressBar();
end

function GoldPlanner:UpdateProgressBar()
    if not self.progressBar then
        return;
    end

    local function TrimToGold(money) return math.floor(money / 10000) * 10000; end
    local frame = self.progressBar;
    local sformat = string.format;
    local goal = self:GetGoal();
    local total = self:GetTotalCopper();

    if goal <= 0 then
        frame.progress.bar:SetValue(0);
        frame.progress.bar.text:SetText(self.STRINGS.EMPTY_STRING);
    else
        local goalProgress = self:GetGoalProgress();
        frame.progress.bar:SetValue(goalProgress);
        frame.progress.bar.text:SetText(sformat("%s / %s", GetMoneyString(TrimToGold(total), true), GetMoneyString(TrimToGold(goal), true)));
    end
end