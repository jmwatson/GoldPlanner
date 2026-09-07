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
    background:SetColorTexture(0, 0, 0, 0.9);

    local title = dashboard:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge");
    title:SetPoint("TOP", 0, -20);
    title:SetText(self.STRINGS.ADDON_TITLE);

    local closeButton = CreateFrame("Button", nil, dashboard, "UIPanelCloseButton");
    closeButton:SetPoint("TOPRIGHT", -5, -5);

    self.dashboard = dashboard;
end

function GoldPlanner:ToggleDashboard()
    if self.dashboard:IsShown() then
        self.dashboard:Hide();
    else
        self.dashboard:Show();
    end
end
