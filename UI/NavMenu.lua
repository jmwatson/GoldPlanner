local _, GoldPlanner = ...;

GoldPlanner.UI = GoldPlanner.UI or {};

local NavMenu = {};
GoldPlanner.UI.NavMenu = NavMenu;

local NAV_ITEM_HEIGHT = 24;
local NAV_ITEM_SPACING = 2;
local NAV_ITEM_TEXT_INSET = 10;

local SELECTED_COLOR = { 1, 0.82, 0 };
local UNSELECTED_COLOR = { 0.8, 0.8, 0.8 };

local NavMenuMixin = {};

function NavMenuMixin:AddItem(text, panel, onSelect)
    local index = #self.items + 1;

    local button = CreateFrame("Button", nil, self);
    button:SetHeight(NAV_ITEM_HEIGHT);
    button:SetPoint("TOPLEFT", 0, -((index - 1) * (NAV_ITEM_HEIGHT + NAV_ITEM_SPACING)));
    button:SetPoint("RIGHT", self, "RIGHT", 0, 0);

    local background = button:CreateTexture(nil, "BACKGROUND");
    background:SetAllPoints();
    background:SetColorTexture(1, 1, 1, 0.08);
    background:Hide();
    button.background = background;

    local label = button:CreateFontString(nil, "OVERLAY", "GameFontNormal");
    label:SetPoint("LEFT", NAV_ITEM_TEXT_INSET, 0);
    label:SetJustifyH("LEFT");
    label:SetText(text);
    button.label = label;

    button:SetScript("OnEnter", function()
        if self.selectedIndex ~= index then
            background:Show();
        end
    end);

    button:SetScript("OnLeave", function()
        if self.selectedIndex ~= index then
            background:Hide();
        end
    end);

    panel:Hide();

    local item = {
        button = button,
        panel = panel,
        onSelect = onSelect,
    };

    self.items[index] = item;

    button:SetScript("OnClick", function()
        self:SelectItem(index);
    end);

    if not self.selectedIndex then
        self:SelectItem(index);
    end

    return item;
end

function NavMenuMixin:SelectItem(index)
    if self.selectedIndex == index then
        return;
    end

    for i, item in ipairs(self.items) do
        local isSelected = (i == index);

        item.panel:SetShown(isSelected);
        item.button.background:SetShown(isSelected);
        item.button.label:SetTextColor(unpack(isSelected and SELECTED_COLOR or UNSELECTED_COLOR));
    end

    self.selectedIndex = index;

    local item = self.items[index];

    if item.onSelect then
        item.onSelect();
    end
end

-- width: optional, defaults to 110.
function NavMenu:Create(parent, width)
    local menu = CreateFrame("Frame", nil, parent);
    menu:SetWidth(width or 110);
    menu.items = {};

    Mixin(menu, NavMenuMixin);

    local separator = menu:CreateTexture(nil, "ARTWORK");
    separator:SetPoint("TOPRIGHT", 0, 0);
    separator:SetPoint("BOTTOMRIGHT", 0, 0);
    separator:SetWidth(1);
    separator:SetColorTexture(1, 1, 1, 0.15);

    return menu;
end