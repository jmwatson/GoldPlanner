local _, GoldPlanner = ...;

function GoldPlanner:BuildDashboard()
    if self.dashboard then
        return;
    end

    local dashboard = CreateFrame("Frame", "GoldPlannerDashboard", UIParent);

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

    local background = dashboard:CreateTexture(nil, "BACKGROUND");
    background:SetAllPoints();
    background:SetColorTexture(0, 0, 0, 1);

    local title = dashboard:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge");
    title:SetPoint("TOP", 0, -20);
    title:SetText(self.STRINGS.ADDON_TITLE);

    local closeButton = CreateFrame("Button", nil, dashboard, "UIPanelCloseButton");
    closeButton:SetPoint("TOPRIGHT", -5, -5);

    local characterGold = dashboard:CreateFontString(nil, "OVERLAY", "GameFontNormal");
    characterGold:SetPoint("TOPLEFT", 20, -70);

    local warbandGold = dashboard:CreateFontString(nil, "OVERLAY", "GameFontNormal");
    warbandGold:SetPoint("TOPLEFT", 20, -100);

    local totalGold = dashboard:CreateFontString(nil, "OVERLAY", "GameFontNormal");
    totalGold:SetPoint("TOPLEFT", 20, -130);

    dashboard.characterGold = characterGold;
    dashboard.warbandGold = warbandGold;
    dashboard.totalGold = totalGold;

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
end

function GoldPlanner:ToggleDashboard()
    if self.dashboard:IsShown() then
        self.dashboard:Hide();
    else
        self:UpdateDashboard();
        self.dashboard:Show();
    end
end
