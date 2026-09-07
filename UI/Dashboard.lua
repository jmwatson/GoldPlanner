local _, GoldPlanner = ...;

function BuildDashboard()
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
    title:SetText(GoldPlanner.STRINGS.ADDON_TITLE);

    local closeButton = CreateFrame("Button", nil, dashboard, "UIPanelCloseButton");
    closeButton:SetPoint("TOPRIGHT", -5, -5);

    function GoldPlanner:ToggleDashboard()
        if dashboard:IsShown() then
            dashboard:Hide();
        else
            dashboard:Show();
        end
    end

    return dashboard;
end

SLASH_GOLDPLANNER1 = GoldPlanner.STRINGS.SLASH_COMMAND;
SLASH_GOLDPLANNER2 = GoldPlanner.STRINGS.SLASH_COMMAND_SHORT;

SlashCmdList["GOLDPLANNER"] = function()
    GoldPlanner:ToggleDashboard();
end
