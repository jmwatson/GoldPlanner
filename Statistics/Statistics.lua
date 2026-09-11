local _, GoldPlanner = ...;

local DAY = 86400;
local HOUR = 3600;
local MINUTE = 60;
local STATISTICS_WINDOW = HOUR;

local function FormatDuration(seconds)
    local days = math.floor(seconds / DAY);
    seconds = seconds % DAY;

    local hours = math.floor(seconds / HOUR);
    seconds = seconds % HOUR;

    local minutes = math.floor(seconds / MINUTE);
    if days > 0 then
        return string.format("%dd %dh %dm", days, hours, minutes);
    elseif hours > 0 then
        return string.format("%dh %dm", hours, minutes);
    end

    return string.format("%dm", minutes);
end

function GoldPlanner:GetMoneyRate(windowSeconds)
    local history = self.db.totalHistory;

    -- Not enough history to calculate a rate
    if #history < 2 then
        return nil;
    end

    local latest = history[#history];
    local cutoff = latest.timestamp - windowSeconds;
    local oldest = nil;

    for i = 1, #history do
        local snapshot = history[i];

        if snapshot.timestamp >= cutoff then
            oldest = snapshot;
            break;
        end
    end

    if not oldest then
        oldest = history[1];
    end

    local elapsed = latest.timestamp - oldest.timestamp;

    -- Another window check to make sure we don't divide by zero
    if elapsed <= 0 then
        return nil;
    end

    local copperDelta = latest.copper - oldest.copper;

    return {
        copperDelta = copperDelta,
        elapsed = elapsed,
        rate = copperDelta / elapsed,
    };
end

function GoldPlanner:GetTimeToAmount(currentCopper, targetCopper, rate)
    local copperDelta = targetCopper - currentCopper;

    if not rate or rate <= 0 then
        return nil;
    end

    if copperDelta <= 0 then
        return 0;
    end

    return copperDelta / rate;
end

function GoldPlanner:GetMoneyRateDisplay()
    local statistics = self:GetMoneyRate(STATISTICS_WINDOW);

    if not statistics then
        return nil;
    end

    local windowRate = statistics.rate * STATISTICS_WINDOW;

    return GetMoneyString(windowRate, true);
end

function GoldPlanner:GetTimeToGoalDisplay()
    local goal = self:GetGoal();
    local totalCopper = self:GetTotalCopper();
    local statistics = self:GetMoneyRate(STATISTICS_WINDOW);

    if (goal <= 0) or (not statistics or statistics.rate <= 0) then
        return nil;
    elseif totalCopper >= goal then
        return self.STRINGS.REACHED;
    end

    local seconds = self:GetTimeToAmount(totalCopper, goal, statistics.rate);

    if not seconds then
        return nil;
    end
    
    return FormatDuration(seconds);
end