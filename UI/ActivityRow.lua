local _, GoldPlanner = ...;

GoldPlanner.UI = GoldPlanner.UI or {};

local ActivityRow = {};
GoldPlanner.UI.ActivityRow = ActivityRow;

local EVENTS = GoldPlanner.EVENTS;

ActivityRow.HEIGHT = 18;

local DEFAULT_VALUE_WIDTH = 100;
local COLUMN_SPACING = 8;

local TRACKED_BACKGROUND_COLOR = { 1, 0.82, 0, 0.12 };
local TRACKED_TITLE_COLOR = { 1, 0.82, 0 };

local rows = {};

local ActivityRowMixin = {};

function ActivityRowMixin:IsTracked()
    local isTracked = self.config.isTracked;

    if self.activityID == nil or not isTracked then
        return false;
    end

    return isTracked(self.activityID) and true or false;
end

function ActivityRowMixin:ShowTooltip()
    local buildTooltip = self.config.tooltip;

    if not buildTooltip or self.activityID == nil then
        return;
    end

    GameTooltip:SetOwner(self, "ANCHOR_TOP");
    buildTooltip(GameTooltip, self.activityID, self:IsTracked());
    GameTooltip:Show();
end

function ActivityRowMixin:RefreshTracking()
    local tracked = self:IsTracked();

    self.trackedBackground:SetShown(tracked);
    self.title:SetTextColor(unpack(tracked and TRACKED_TITLE_COLOR or self.defaultTitleColor));

    -- Keep the tooltip in sync if the tracked state changes while hovering
    if GameTooltip:IsShown() and GameTooltip:GetOwner() == self then
        self:ShowTooltip();
    end
end

function ActivityRowMixin:SetActivity(id, valueText, titleText)
    self.activityID = id;
    self.value:SetText(valueText or GoldPlanner.STRINGS.EMPTY_STRING);
    self.title:SetText(titleText or GoldPlanner.STRINGS.EMPTY_STRING);

    self:RefreshTracking();
end

function ActivityRowMixin:HandleClick()
    local id = self.activityID;
    local config = self.config;

    if id == nil then
        return;
    end

    if self:IsTracked() and config.untrack then
        config.untrack(id);
    elseif config.track then
        config.track(id);
    end

    self:RefreshTracking();
end

function ActivityRow.Create(parent, config)
    local row = CreateFrame("Button", nil, parent);
    row:SetHeight(ActivityRow.HEIGHT);

    Mixin(row, ActivityRowMixin);
    row.config = config or {};

    local trackedBackground = row:CreateTexture(nil, "BACKGROUND");
    trackedBackground:SetAllPoints();
    trackedBackground:SetColorTexture(unpack(TRACKED_BACKGROUND_COLOR));
    trackedBackground:Hide();
    row.trackedBackground = trackedBackground;

    local highlight = row:CreateTexture(nil, "HIGHLIGHT");
    highlight:SetAllPoints();
    highlight:SetColorTexture(1, 1, 1, 0.08);

    row.value = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall");
    row.value:SetPoint("LEFT", 0, 0);
    row.value:SetWidth(row.config.valueWidth or DEFAULT_VALUE_WIDTH);
    row.value:SetJustifyH("LEFT");

    row.title = row:CreateFontString(nil, "OVERLAY", "GameFontWhiteSmall");
    row.title:SetPoint("LEFT", row.value, "RIGHT", COLUMN_SPACING, 0);
    row.title:SetPoint("RIGHT", row, "RIGHT", 0, 0);
    row.title:SetJustifyH("LEFT");
    row.title:SetWordWrap(false);

    local r, g, b = row.title:GetTextColor();
    row.defaultTitleColor = { r, g, b };

    row:SetScript("OnClick", row.HandleClick);

    row:SetScript("OnEnter", row.ShowTooltip);

    row:SetScript("OnLeave", function()
        GameTooltip:Hide();
    end);

    row:SetScript("OnShow", row.RefreshTracking);

    rows[row] = true;

    return row;
end

function ActivityRow.RefreshAll()
    for row in pairs(rows) do
        if row:IsVisible() then
            row:RefreshTracking();
        end
    end
end

EventRegistry:RegisterFrameEventAndCallback(EVENTS.QUEST_WATCH_LIST_CHANGED, ActivityRow.RefreshAll, ActivityRow);
