local _, GoldPlanner = ...;

GoldPlanner.UI = GoldPlanner.UI or {};

local Dashboard = {};
GoldPlanner.UI.Dashboard = Dashboard;

local PANEL_PADDING = 16;
local NAV_WIDTH = 110;

local function CreatePanel(parent)
    local panel = CreateFrame("Frame", nil, parent);
    panel:SetAllPoints(parent);
    panel:Hide();

    local content = CreateFrame("Frame", nil, panel);
    content:SetPoint("TOPLEFT", PANEL_PADDING, -PANEL_PADDING);
    content:SetPoint("BOTTOMRIGHT", -PANEL_PADDING, PANEL_PADDING);

    panel.content = content;

    return panel;
end


function Dashboard:Build()
    if self.dashboard then
        return;
    end

    local dashboard = CreateFrame("Frame", "GoldPlannerDashboard", UIParent, "BasicFrameTemplate");
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
    title:SetText(GoldPlanner.STRINGS.ADDON_TITLE);

    local navMenu = GoldPlanner:CreateNavMenu(dashboard, NAV_WIDTH);
    navMenu:SetPoint("TOPLEFT", dashboard, "TOPLEFT", 4, -30);
    navMenu:SetPoint("BOTTOMLEFT", dashboard, "BOTTOMLEFT", 4, 4);

    local contentArea = CreateFrame("Frame", nil, dashboard);
    contentArea:SetPoint("TOPLEFT", navMenu, "TOPRIGHT", 0, 0);
    contentArea:SetPoint("BOTTOMRIGHT", dashboard, "BOTTOMRIGHT", -4, 4);

    local overviewPanel = CreatePanel(contentArea);
    local worldQuestPanel = CreatePanel(contentArea);

    navMenu:AddItem("Overview", overviewPanel);
    navMenu:AddItem("World Quests", worldQuestPanel, function()
        GoldPlanner.UI.WorldQuests:Update();

        if not GoldPlanner.Runtime.HasScannedWorldQuests then
            GoldPlanner.Runtime.HasScannedWorldQuests = true;
            GoldPlanner:RefreshWorldQuestGold();
        end
    end);

    GoldPlanner.UI.Overview:Build(overviewPanel.content);
    GoldPlanner.UI.WorldQuests:Build(worldQuestPanel.content);

    dashboard.navMenu = navMenu;
    dashboard.overviewPanel = overviewPanel;
    dashboard.activitiesPanel = worldQuestPanel;

    self.dashboard = dashboard;

    GoldPlanner.UI.Overview:Update();
end

function Dashboard:Toggle()
    if self.dashboard:IsShown() then
        self.dashboard:Hide();
    else
        GoldPlanner.UI.Overview:Update();
        self.dashboard:Show();
    end
end
