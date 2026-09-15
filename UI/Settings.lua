local _, GoldPlanner = ...;

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
    local showSetting = Settings.RegisterAddOnSetting(
        category,
        addonName .. "_" .. name:gsub("%s+", ""),
        variable,
        settings,
        type(defaultValue),
        name,
        defaultValue);
    showSetting:SetValueChangedCallback(function(_, value)
        GoldPlanner:SetProgressBarLocked(value);
    end);
    Settings.CreateCheckbox(category, showSetting, description);
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

function GoldPlanner:BuildSettings()
    if self.settingsCategory then
        return;
    end

    local addonName = GoldPlanner.name;

    local category = Settings.RegisterVerticalLayoutCategory(self.STRINGS.ADDON_TITLE);
    Settings.RegisterAddOnCategory(category);

    local progressBarSettings = self.db.settings.progressBar;
    BuildShowProgressBar(addonName, category, progressBarSettings);
    BuildLockProgressBar(addonName, category, progressBarSettings);
    BuildProgressWidth(addonName, category, progressBarSettings);
    BuildProgressHeight(addonName, category, progressBarSettings);

    self.settingsCategory = category;
end