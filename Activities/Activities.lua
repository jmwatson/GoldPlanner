local _, GoldPlanner = ...;

local ACTIVITIES = {
    {
        id = "world_quests",
        name = "World Quests",
        category = "Quests",
    },
    {
        id = "gathering",
        name = "Gathering",
        category = "Professions",
    },
    {
        id = "crafting",
        name = "Crafting",
        category = "Professions",
    },
    {
        id = "auction_house",
        name = "Auction House",
        category = "Trading",
    },
    {
        id = "dungeons",
        name = "Dungeons",
        category = "Content",
    },
    {
        id = "raids",
        name = "Raids",
        category = "Content",
    },
    {
        id = "delves",
        name = "Delves",
        category = "Content",
    },
};

function GoldPlanner:GetActivities()
    return ACTIVITIES;
end

function GoldPlanner:GetActivity(id)
    for _, activity in ipairs(ACTIVITIES) do
        if activity.id == id then
            return activity;
        end
    end

    return nil;
end