local _, GoldPlanner = ...;

local DEFAULT_DATABASE = {
    version = 1,
    lastCompaction = nil;
    characters = {},
    warband = {
        copper = 0,
        history = {},
    },
    totalHistory = {},
    goal = {
        copper = 0,
    },
    settings = {
        progressBar = {
            point = "TOP",
            x = 0,
            y = 0,
            width = 550,
            height = 14,
            fillColor = { 0.8, 0.55, 0 },
            borderColor = { 0, 0, 0, 1 },
            locked = false,
            show = true,
        },
        statsBox = {
            point = "TOP",
            x = 0,
            y = -34,
            padding = 3,
            fillColor = { 0.8, 0.55, 0 },
            borderColor = { 0, 0, 0, 1 },
            locked = false,
            show = true,
        },
    },
};

local function CopyDefaults(source, target)
    for key, value in pairs(source) do
        if target[key] == nil then
            if type(value) == "table" then
                target[key] = {};
                CopyDefaults(value, target[key]);
            else
                target[key] = value;
            end
        elseif type(value) == "table" and type(target[key]) == "table" then
            CopyDefaults(value, target[key]);
        end
    end
end

function GoldPlanner:InitializeDatabase()
    if not GoldPlannerDB then
        GoldPlannerDB = {};
    end

    CopyDefaults(DEFAULT_DATABASE, GoldPlannerDB);

    self.db = GoldPlannerDB;
end

function GoldPlanner:ResetProgressBar()
    if not GoldPlannerDB then
        self:InitializeDatabase();
    end

    local defaults = {}
    CopyDefaults(DEFAULT_DATABASE.settings.progressBar, defaults);
    self.db.settings.progressBar = defaults;
end

function GoldPlanner:ResetStatsBoxSettings()
    if not GoldPlannerDB then
        self:InitializeDatabase();
    end

    local defaults = {};
    CopyDefaults(DEFAULT_DATABASE.settings.statsBox, defaults);
    self.db.settings.statsBox = defaults;
end