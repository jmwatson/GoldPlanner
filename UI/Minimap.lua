local _, GoldPlanner = ...;

GoldPlanner.UI = GoldPlanner.UI or {};

local _Minimap = {};
GoldPlanner.UI.Minimap = _Minimap;

local EVENTS = GoldPlanner.EVENTS;
local ColorText = GoldPlanner.Utils.ColorText;

local ICON_TEXTURE = "Interface\\Icons\\Inv_misc_coin_01";
local BUTTON_SIZE = 31;
local RADIUS_OFFSET = 5;

local ICON_SIZE = 17;
local ICON_SIZE_PRESSED = ICON_SIZE - 2;
local ICON_CENTER_X = 15.5;
local ICON_CENTER_Y = -14.5;

local function GetStartOfToday()
    local today = date("*t");
    today.hour = 0;
    today.min = 0;
    today.sec = 0;
    return time(today);
end

local function PositionButton(button, angle)
    local radius = (Minimap:GetWidth() / 2) + RADIUS_OFFSET;
    local radians = math.rad(angle);

    button:ClearAllPoints();
    button:SetPoint("CENTER", Minimap, "CENTER", math.cos(radians) * radius, math.sin(radians) * radius);
end

local function GetCursorAngle()
    local centerX, centerY = Minimap:GetCenter();
    local scale = Minimap:GetEffectiveScale();
    local cursorX, cursorY = GetCursorPosition();

    cursorX = cursorX / scale;
    cursorY = cursorY / scale;

    return math.deg(math.atan2(cursorY - centerY, cursorX - centerX)) % 360;
end

local function ShowTooltip(button)
    local GP = GoldPlanner;
    local Stats = GP.Data.Statistics;
    local Format = GP.UI.Format;
    local STRINGS = GP.STRINGS;

    local total = GP.Data.Gold:GetTotalCopper();
    local earnedToday = Stats:GetCopperEarnedSince(GetStartOfToday(), total);

    GameTooltip:SetOwner(button, "ANCHOR_LEFT");
    GameTooltip:ClearLines();
    GameTooltip:AddLine(STRINGS.ADDON_TITLE, 1, 0.82, 0);
    GameTooltip:AddLine(" ");

    GameTooltip:AddDoubleLine(STRINGS.TOTAL_GOLD .. ":", GetMoneyString(total, true), 1, 1, 1, 1, 1, 1);
    GameTooltip:AddDoubleLine(STRINGS.TODAY .. ":", Format.SignedMoney(earnedToday), 1, 1, 1, 1, 1, 1);
    GameTooltip:AddDoubleLine(STRINGS.RATE .. ":", Format.Rate(Stats:GetHourlyRate(), false), 1, 1, 1, 1, 1, 1);

    GameTooltip:AddLine(" ");
    GameTooltip:AddLine(ColorText("Left-Click:", GP.COLORS.GREEN) .. "Toggle dashboard", 0.8, 0.8, 0.8);
    GameTooltip:AddLine(ColorText("Right-Click:", GP.COLORS.GREEN) .. "Open settings", 0.8, 0.8, 0.8);
    GameTooltip:AddLine(ColorText("Drag:", GP.COLORS.GREEN) .. "Move button", 0.8, 0.8, 0.8);
    GameTooltip:Show();
end

function _Minimap:Build()
    if self.button then
        return;
    end

    local settings = GoldPlanner.db.settings.minimap;

    local button = CreateFrame("Button", "GoldPlannerMinimapButton", Minimap);
    button:SetSize(BUTTON_SIZE, BUTTON_SIZE);
    button:SetFrameStrata("MEDIUM");
    button:SetFrameLevel(8);
    button:SetClampedToScreen(true);
    button:RegisterForClicks("LeftButtonUp", "RightButtonUp");
    button:RegisterForDrag("LeftButton");
    button:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoneButton-Highlight");

    local overlay = button:CreateTexture(nil, "OVERLAY");
    overlay:SetSize(53, 53);
    overlay:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder");
    overlay:SetPoint("TOPLEFT");

    local background = button:CreateTexture(nil, "BACKGROUND");
    background:SetSize(20, 20);
    background:SetTexture("Interface\\Minimap\\UI-Minimap-Background");
    background:SetPoint("TOPLEFT", 7, -5);

    local icon = button:CreateTexture(nil, "ARTWORK");
    icon:SetSize(17, 17);
    icon:SetTexture(ICON_TEXTURE);
    icon:SetTexCoord(0.05, 0.95, 0.05, 0.95);
    icon:SetPoint("CENTER", button, "TOPLEFT", ICON_CENTER_X, ICON_CENTER_Y);
    button.icon = icon;

    button:SetScript("OnMouseDown", function(self)
        self.icon:SetSize(ICON_SIZE_PRESSED, ICON_SIZE_PRESSED);
    end);

    button:SetScript("OnMouseUp", function(self)
        self.icon:SetSize(ICON_SIZE, ICON_SIZE);
    end);

    button:SetScript("OnClick", function(_, mouseButton)
        if mouseButton == "LeftButton" then
            GoldPlanner.UI.Dashboard:Toggle();
        elseif mouseButton == "RightButton" then
            Settings.OpenToCategory(GoldPlanner.UI.Settings.category:GetID());
        end
    end);

    button:SetScript("OnEnter", function(self)
        ShowTooltip(self);
    end);

    button:SetScript("OnLeave", function()
        GameTooltip:Hide();
    end);

    button:SetScript("OnDragStart", function(self)
        GameTooltip:Hide();

        self:SetScript("OnUpdate", function(frame)
            PositionButton(frame, GetCursorAngle());
        end);
    end);

    button:SetScript("OnDragStop", function(self)
        self:SetScript("OnUpdate", nil);
        _Minimap:SaveAngle(GetCursorAngle());
        PositionButton(self, GoldPlanner.db.settings.minimap.angle);
    end);

    PositionButton(button, settings.angle);
    button:SetShown(settings.show);

    self.button = button;

    self:RegisterEvents();
end

function _Minimap:ApplySettings()
    local button = self.button;

    if button then
        local settings = GoldPlanner.db.settings.minimap;

        PositionButton(button, settings.angle);
        button:SetShown(settings.show);
    end
end

function _Minimap:Show(show)
    if self.button then
        GoldPlanner.db.settings.minimap.show = show;
        self.button:SetShown(show);
    end
end

function _Minimap:SaveAngle(angle)
    GoldPlanner.db.settings.minimap.angle = angle;
end

function _Minimap:Reset()
    local DB = GoldPlanner.DB;

    if not DB:IsInitialized() then
        DB:InitializeDatabase();
    end

    DB:ResetTable(GoldPlanner.db.settings.minimap, DB:GetDefaults().settings.minimap);
end

function _Minimap:OnTotalUpdated()
    local button = self.button;

    if button and button:IsShown() and GameTooltip:GetOwner() == button then
        ShowTooltip(button);
    end
end

function _Minimap:RegisterEvents()
    EventRegistry:RegisterCallback(EVENTS.HISTORY_TOTAL_UPDATED, self.OnTotalUpdated, self);
end

EventRegistry:RegisterFrameEventAndCallback(EVENTS.PLAYER_LOGIN, _Minimap.Build, _Minimap);
