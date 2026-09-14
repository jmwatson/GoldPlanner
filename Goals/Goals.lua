local _, GoldPlanner = ...;

local DAY = 86400;

function GoldPlanner:SetGoal(copper)
    if type(copper) ~= "number" or copper < 0 then
        error("Goal must be a non-negative number.");
    end

    self.db.goal.copper = copper;
end

function GoldPlanner:GetGoal()
    return self.db.goal.copper;
end

function GoldPlanner:GetGoalRemaining()
    local remaining = self:GetGoal() - self:GetTotalCopper();
    return math.max(remaining, 0);
end

function GoldPlanner:GetGoalProgress()
    local goal = self:GetGoal();

    if goal <= 0 then
        return nil;
    end

    return math.min(self:GetTotalCopper() / goal, 1);
end

function GoldPlanner:SetGoalDeadline(timestamp)
    self.db.goal.deadline = timestamp;
end

function GoldPlanner:GetGoalDeadline()
    return self.db.goal.deadline;
end

function GoldPlanner:GetDaysRemaining()
    local deadline = self.db.goal.deadline;

    if not deadline then
        return nil;
    end

    local secondsRemaining = deadline - time();

    if secondsRemaining <= 0 then
        return 0;
    end

    return math.ceil(secondsRemaining / DAY);
end

function GoldPlanner:GetDailyGoal()
    local daysRemaining = self:GetDaysRemaining();

    if not daysRemaining then
        return nil;
    end

    local remaining = self:GetGoalRemaining();

    if remaining <= 0 then
        return 0;
    end

    return remaining / math.max(1, daysRemaining)
end