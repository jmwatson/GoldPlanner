local _, GoldPlanner = ...;

-- GoldPlanner.Core = GoldPlanner.Core or {};

local DB = {};
GoldPlanner.DB = DB;

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
        minimap = {
            angle = 225,
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

function DB:ResetTable(target, defaults)
    for key in pairs(target) do
        target[key] = nil;
    end

    CopyDefaults(defaults, target);
end

function DB:InitializeDatabase()
    if not GoldPlannerDB then
        GoldPlannerDB = {};
    end

    if not GoldPlanner.db then
        CopyDefaults(DEFAULT_DATABASE, GoldPlannerDB);
        GoldPlanner.db = GoldPlannerDB;
    end
end

function DB:GetDefaults()
    return DEFAULT_DATABASE;
end

function DB:IsInitialized()
    if not GoldPlanner.db then
        return false;
    end

    return true;
end