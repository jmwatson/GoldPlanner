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

function GoldPlanner:BuildActivities(parent)
    local activities = CreateFrame("Frame", nil, parent);
    activities:SetPoint("TOPLEFT", 20, -340);
    activities:SetSize(460, 100);

    local activitiesTitle = activities:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge");
    activitiesTitle:SetPoint("TOPLEFT", 0, 0);
    activitiesTitle:SetText("Activities");

    local activityList = self:GetActivities();

    for index, activity in ipairs(activityList) do
        local yOffset = -(index * 20);

        local activityName = activities:CreateFontString(nil, "OVERLAY", "GameFontNormal");
        activityName:SetPoint("TOPLEFT", 0, yOffset);
        activityName:SetText(activity.name);

        local activityCategory = activities:CreateFontString(nil, "OVERLAY", "GameFontNormal");
        activityCategory:SetPoint("TOPLEFT", 250, yOffset);
        activityCategory:SetText(activity.category);

        activities[activity.id] = {
            name = activityName,
            category = activityCategory,
        };
    end

    parent.activities = activities;
end