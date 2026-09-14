local _, GoldPlanner = ...;

local trim = GoldPlanner.TrimGold;

function GoldPlanner:BuildProgressBar()
    if self.progressBar then
        return;
    end

    local settings = GoldPlanner.db.settings.progressBar;

    local frame = CreateFrame("Frame", "GoldPlannerProgressBar", UIParent);
    frame:SetSize(settings.width, settings.height);
    frame:SetPoint(settings.point, UIParent, settings.point, settings.x, settings.y);
    frame:SetMovable(true);
    frame:SetClampedToScreen(true);
    frame:EnableMouse(not settings.locked);
    frame:RegisterForDrag("RightButton");

    frame:SetScript("OnDragStart", function(self)
        self:StartMoving();
    end);

    frame:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing();
        GoldPlanner:SaveProgressBarPosition();
    end);

    frame:Show();

    local inset = 3;
    local progress = CreateFrame("StatusBar", nil, frame, "BackdropTemplate");
    progress:SetPoint("TOPLEFT", inset, -inset);
    progress:SetPoint("BOTTOMRIGHT", -inset, inset);
    progress:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    });
    progress:SetBackdropBorderColor(settings.borderColor[1], settings.borderColor[2], settings.borderColor[3], settings.borderColor[4]);

    local barInset = 1;
    progress.bar = CreateFrame("StatusBar", nil, progress);
    progress.bar:SetPoint("TOPLEFT", barInset, -barInset);
    progress.bar:SetPoint("BOTTOMRIGHT", -barInset, barInset);
    progress.bar:SetMinMaxValues(0, 1);
    progress.bar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar");
    progress.bar:SetStatusBarColor(settings.fillColor[1], settings.fillColor[2], settings.fillColor[3]);

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

    local sformat = string.format;
    local frame = self.progressBar;
    local goal = self:GetGoal();
    local total = self:GetTotalCopper();

    if goal <= 0 then
        frame.progress.bar:SetValue(0);
        frame.progress.bar.text:SetText(self.STRINGS.EMPTY_STRING);
    else
        local goalProgress = self:GetGoalProgress();
        local text = frame:GetWidth() >= 200 and
            sformat("%s / %s", GetMoneyString(trim(total), true), GetMoneyString(trim(goal), true)) or
            sformat("%.1f%%", goalProgress * 100);
        frame.progress.bar:SetValue(goalProgress);
        frame.progress.bar.text:SetText(text);
    end
end

function GoldPlanner:ApplyProgressBarSettings()
    local frame = self.progressBar;

    if frame then
        local settings = self.db.settings.progressBar;

        frame:ClearAllPoints();
        frame:SetPoint(settings.point, UIParent, settings.point, settings.x, settings.y);
        frame:SetSize(settings.width, settings.height);
        frame:EnableMouse(not settings.locked);
        frame:SetShown(settings.show);

        GoldPlanner:SetProgressBarBorderColor(settings.borderColor);
        GoldPlanner:SetProgressBarColor(settings.fillColor);
    end
end


function GoldPlanner:SetProgressBarSize(width, height)
    if self.progressBar then
        self.db.settings.progressBar.width = width;
        self.db.settings.progressBar.height = height;
        self.progressBar:SetSize(width, height);
    end
end

function GoldPlanner:SetProgressBarColor(fill)
    if self.progressBar then
        self.db.settings.progressBar.fillColor = fill;
        self.progressBar.progress.bar:SetStatusBarColor(fill[1], fill[2], fill[3]);
    end
end

function GoldPlanner:SetProgressBarBorderColor(border)
    if self.progressBar then
        self.db.settings.progressBar.borderColor = border;
        self.progressBar.progress:SetBackdropBorderColor(border[1], border[2], border[3], border[4]);
    end
end

function GoldPlanner:SetProgressBarLocked(lock)
    if self.progressBar then
        self.db.settings.progressBar.locked = lock;
        self.progressBar:EnableMouse(not lock);
    end
end

function GoldPlanner:ShowProgressBar(show)
    if self.progressBar then
        self.db.settings.progressBar.show = show;

        if show then
            self.progressBar:Show();
        else
            self.progressBar:Hide();
        end
    end
end

function GoldPlanner:SaveProgressBarPosition()
    local frame = self.progressBar;

    if frame then
        local point, _, _, x, y = frame:GetPoint();
        local settings = self.db.settings.progressBar;

        settings.point = point;
        settings.x = x;
        settings.y = y;
    end
end
