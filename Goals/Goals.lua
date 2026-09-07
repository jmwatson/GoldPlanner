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