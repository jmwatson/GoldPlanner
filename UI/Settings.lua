local _, GoldPlanner = ...;

local fontOptions = {
    "GameFontNormalHuge",
    "GameFontNormalLarge",
    "GameFontNormal",
    "GameFontNormalSmall",
    "GameFontHighlightLarge",
    "GameFontHighlight",
    "GameFontHighlightSmall",
    "GameFontDisableLarge",
    "GameFontDisable",
    "GameFontDisableSmall",
    "SystemFont_Tiny",
    "SystemFont_Small",
    "SystemFont_Med1",
    "SystemFont_Med2",
    "SystemFont_Med3",
    "SystemFont_Large",
    "SystemFont_Huge1",
    "SystemFont_Huge2",
    "GameTooltipText",
    "GameTooltipTextSmall",
    "NumberFontNormal",
    "NumberFontNormalSmall",
    "ChatFontNormal",
    "CombatTextFont",
};

local function BuildGoalAmount(parent)
    local title = parent:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge");
    title:SetPoint("TOPLEFT", 16, -16);
    title:SetText("Goal Amount (gold)");

    local editbox = CreateFrame("EditBox", nil, parent, "InputBoxTemplate");
    editbox:SetAutoFocus(false);
    editbox:SetNumeric(true);
    editbox:SetSize(150, 30);
    editbox:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 4, -12);

    editbox:SetScript("OnEnterPressed", function(self)
        local gold = tonumber(self:GetText());

        if gold and gold > 0 then
            GoldPlanner:SetGoal(gold * 10000);
            GoldPlanner:UpdateDashboard();
            GoldPlanner:UpdateProgressBar();
            GoldPlanner:UpdateStatsBox();
        end

        self:ClearFocus();
    end);

    editbox:SetScript("OnEscapePressed", function(self)
        editbox:SetText(tostring(math.floor(GoldPlanner:GetGoal() / 10000)));
        self:ClearFocus();
    end);

    return editbox;
end

local function BuildGoalDeadline(parent, anchor)
    local title = parent:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge");
    title:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", -4, -24);
    title:SetText("Goal Deadline (days)");

    local editbox = CreateFrame("EditBox", nil, parent, "InputBoxTemplate");
    editbox:SetAutoFocus(false);
    editbox:SetNumeric(true);
    editbox:SetSize(150, 30);
    editbox:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 4, -12);

    editbox:SetScript("OnEnterPressed", function(self)
        local days = tonumber(self:GetText());

        if days and days > 0 then
            GoldPlanner:SetGoalDeadline(time() + (days * 86400));
            GoldPlanner:UpdateDashboard();
            GoldPlanner:UpdateStatsBox();
        end

        self:ClearFocus();
    end);

    editbox:SetScript("OnEscapePressed", function(self)
        local deadline = GoldPlanner.db.goal.deadline;
        editbox:SetText(deadline and tostring(math.floor((GoldPlanner.db.goal.deadline - time()) / 86400)) or "");
        self:ClearFocus();
    end);

    return editbox;
end

local function BuildShowProgressBar(addonName, category, settings)
    local variable = "show";
    local name = "Show Progress Bar";
    local description = "Show the progress bar.";
    local defaultValue = true;
    local showSetting = Settings.RegisterAddOnSetting(
        category,
        addonName .. "_" .. name:gsub("%s+", ""),
        variable,
        settings,
        type(defaultValue),
        name,
        defaultValue);
    showSetting:SetValueChangedCallback(function(_, value)
        GoldPlanner:ShowProgressBar(value);
    end);
    Settings.CreateCheckbox(category, showSetting, description);
end

local function BuildLockProgressBar(addonName, category, settings)
    local variable = "locked";
    local name = "Lock Progress Bar";
    local description = "Lock the movement of the progress bar.";
    local defaultValue = false;
    local lockSetting = Settings.RegisterAddOnSetting(
        category,
        addonName .. "_" .. name:gsub("%s+", ""),
        variable,
        settings,
        type(defaultValue),
        name,
        defaultValue);
    lockSetting:SetValueChangedCallback(function(_, value)
        GoldPlanner:SetProgressBarLocked(value);
    end);
    Settings.CreateCheckbox(category, lockSetting, description);
end

local function BuildProgressWidth(addonName, category, settings)
    local variable = "width";
    local name = "Progress Bar Width";
    local description = "Set the width of the progress bar.";
    local default = 550;
    local min = 200;
    local max = 800;
    local step = 10;
    local widthSetting = Settings.RegisterAddOnSetting(
        category,
        addonName .. "_" .. name:gsub("%s+", ""),
        variable,
        settings,
        type(default),
        name,
        default);
    local widthOptions = Settings.CreateSliderOptions(min, max, step);
    widthOptions:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right);
    Settings.CreateSlider(category, widthSetting, widthOptions, description);

    widthSetting:SetValueChangedCallback(function(_, value)
        GoldPlanner:SetProgressBarSize(
            value,
            settings.height
        )
    end);
end

local function BuildProgressHeight(addonName, category, settings)
    local variable = "height";
    local name = "Progress Bar Height";
    local description = "Set the height of the progress bar.";
    local defaultValue = 14;
    local min = 8;
    local max = 100;
    local step = 1;
    local heightSetting = Settings.RegisterAddOnSetting(
        category,
        addonName .. "_" .. name:gsub("%s+", ""),
        variable,
        settings,
        type(defaultValue),
        name,
        defaultValue);
    local heightOptions = Settings.CreateSliderOptions(min, max, step);
    heightOptions:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right);
    Settings.CreateSlider(category, heightSetting, heightOptions, description);

    heightSetting:SetValueChangedCallback(function(_, value)
        GoldPlanner:SetProgressBarSize(
            settings.width,
            value
        );
    end);
end

local function BuildProgressFont(addonName, category, settings)
end

local function BuildShowStatsBox(addonName, category, settings)
    local variable = "show";
    local name = "Show Stats Box";
    local description = "Show the stats box.";
    local defaultValue = true;
    local showSetting = Settings.RegisterAddOnSetting(
        category,
        addonName .. "_" .. name:gsub("%s+", ""),
        variable,
        settings,
        type(defaultValue),
        name,
        defaultValue);
    showSetting:SetValueChangedCallback(function(_, value)
        GoldPlanner:ShowStatsBox(value);
    end);
    Settings.CreateCheckbox(category, showSetting, description);
end

local function BuildLockStatsBox(addonName, category, settings)
    local variable = "locked";
    local name = "Lock Stats Box";
    local description = "Lock the movement of the stats box.";
    local defaultValue = false;
    local lockSetting = Settings.RegisterAddOnSetting(
        category,
        addonName .. "_" .. name:gsub("%s+", ""),
        variable,
        settings,
        type(defaultValue),
        name,
        defaultValue);
    lockSetting:SetValueChangedCallback(function(_, value)
        GoldPlanner:SetStatsBoxLocked(value);
    end);
    Settings.CreateCheckbox(category, lockSetting, description);
end

local function BuildStatsPadding(addonName, category, settings)
    local variable = "padding";
    local name = "Stats Box Padding";
    local description = "Sets the padding around the stats box.";
    local defaultValue = 3;
    local min = 0;
    local max = 10;
    local step = 0.1;
    local paddingSetting = Settings.RegisterAddOnSetting(
        category,
        addonName .. "_" .. name:gsub("%s+", ""),
        variable,
        settings,
        type(defaultValue),
        name,
        defaultValue
    );
    local options = Settings.CreateSliderOptions(min, max, step);
    options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right);
    Settings.CreateSlider(category, paddingSetting, options, description);

    paddingSetting:SetValueChangedCallback(function(_, value)
        GoldPlanner:SetStatsBoxPadding(
            settings.padding,
            value
        );
    end);
end

local function CreateResetButton(parent, anchor, text, onClickCallback)
        local button = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate");
        button:SetText(text);
        button:SetSize(160, 24);
        button:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", -4, -24);
        button:SetScript("OnClick", onClickCallback);

        return button;
end

function GoldPlanner:BuildSettings()
    if self.settingsCategory then
        return;
    end

    local addonName = GoldPlanner.name;

    local panel = CreateFrame("Frame");
    local category = Settings.RegisterCanvasLayoutCategory(panel, self.STRINGS.ADDON_TITLE);
    Settings.RegisterAddOnCategory(category);

    local goalEditBox = BuildGoalAmount(panel);
    local deadlineEditBox = BuildGoalDeadline(panel, goalEditBox);
    local resetProgressBarButton = CreateResetButton(panel, deadlineEditBox, "Reset Progress Bar", function()
        GoldPlanner:ResetProgressBar();
        GoldPlanner:ApplyProgressBarSettings();
    end);
    local resetStatsBoxButton = CreateResetButton(panel, resetProgressBarButton, "Reset Stats Box", function()
        GoldPlanner:ResetStatsBoxSettings();
        GoldPlanner:ApplyStatsBoxSettings();
    end);

    panel:SetScript("OnShow", function(self)
        goalEditBox:SetText(tostring(math.floor(GoldPlanner:GetGoal() / 10000)));

        local deadline = GoldPlanner.db.goal.deadline;
        deadlineEditBox:SetText(deadline and tostring(math.floor((GoldPlanner.db.goal.deadline - time()) / 86400)) or "");
    end);

    local progressBarCategory = Settings.RegisterVerticalLayoutSubcategory(category, "Progress Bar");
    Settings.RegisterAddOnCategory(progressBarCategory);

    local progressBarSettings = self.db.settings.progressBar;
    BuildShowProgressBar(addonName, progressBarCategory, progressBarSettings);
    BuildLockProgressBar(addonName, progressBarCategory, progressBarSettings);
    BuildProgressWidth(addonName, progressBarCategory, progressBarSettings);
    BuildProgressHeight(addonName, progressBarCategory, progressBarSettings);

    local statsBoxCategory = Settings.RegisterVerticalLayoutSubcategory(category, "Stats Box");
    Settings.RegisterAddOnCategory(statsBoxCategory);

    local statsBoxSettings = self.db.settings.statsBox;
    BuildShowStatsBox(addonName, statsBoxCategory, statsBoxSettings);
    BuildLockStatsBox(addonName, statsBoxCategory, statsBoxSettings);
    BuildStatsPadding(addonName, statsBoxCategory, statsBoxSettings);

    self.settingsCategory = category;
end