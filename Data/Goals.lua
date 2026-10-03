local _, GoldPlanner = ...;

GoldPlanner.Data = GoldPlanner.Data or {};

local Goal = {};
GoldPlanner.Data.Goal = Goal;

local DAY = 86400;

function Goal:Set(copper)
    if type(copper) ~= "number" or copper < 0 then
        error("Goal must be a non-negative number.");
    end

    GoldPlanner.db.goal.copper = copper;
end

function Goal:Get()
    return GoldPlanner.db.goal.copper;
end

function Goal:GetRemaining()
    local remaining = self:Get() - GoldPlanner.Data.Gold:GetTotalCopper();
    return math.max(remaining, 0);
end

function Goal:GetProgress()
    local goal = self:Get();

    if goal <= 0 then
        return nil;
    end

    return math.min(GoldPlanner.Data.Gold:GetTotalCopper() / goal, 1);
end

function Goal:SetDeadline(timestamp)
    if type(timestamp) ~= "number" then
        error("Deadline must be a number");
    end

    GoldPlanner.db.goal.deadline = timestamp;
end

function Goal:GetDeadline()
    return GoldPlanner.db.goal.deadline;
end

function Goal:GetDaysRemaining()
    local deadline = self:GetDeadline();

    if not deadline then
        return nil;
    end

    local secondsRemaining = deadline - time();

    if secondsRemaining <= 0 then
        return 0;
    end

    return math.ceil(secondsRemaining / DAY);
end

function Goal:GetDaily()
    local daysRemaining = self:GetDaysRemaining();

    if not daysRemaining then
        return nil;
    end

    local remaining = self:GetRemaining();

    if remaining <= 0 then
        return 0;
    end

    return remaining / math.max(1, daysRemaining)
end