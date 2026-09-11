local _, GoldPlanner = ...;

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