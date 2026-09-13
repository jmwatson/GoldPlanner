local _, addon = ...;

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

function addon:InitializeDatabase()
    if not GoldPlannerDB then
        GoldPlannerDB = {};
    end

    CopyDefaults(DEFAULT_DATABASE, GoldPlannerDB);

    self.db = GoldPlannerDB;
end