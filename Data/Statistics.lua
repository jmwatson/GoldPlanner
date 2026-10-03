local _, GoldPlanner = ...;

GoldPlanner.Data = GoldPlanner.Data or {};

local Statistics = {};
GoldPlanner.Data.Statistics = Statistics;

local HOUR = 3600;
local STATISTICS_WINDOW = HOUR;

local function GetStartOfToday()
    local today = date("*t");
    today.hour = 0;
    today.min = 0;
    today.sec = 0;
    return time(today);
end

function Statistics:GetMoneyRate(windowSeconds)
    local window = GoldPlanner.Data.History:GetWindow(windowSeconds);

    -- Not enough history to calculate a rate
    if not window then
        return nil;
    end

    local elapsed = window.endTime - window.startTime;

    if elapsed <= 0 then
        return nil;
    end

    local copperDelta = window.endCopper - window.startCopper;

    return {
        copperDelta = copperDelta,
        elapsed = elapsed,
        rate = copperDelta / elapsed,
    };
end

function Statistics:GetHourlyRate()
    local statistics = self:GetMoneyRate(STATISTICS_WINDOW);

    if not statistics then
        return nil;
    end

    return statistics.rate * STATISTICS_WINDOW;
end

function Statistics:GetCopperEarnedSince(timestamp, currentCopper)
    local startCopper = GoldPlanner.Data.History:GetCopperAt(timestamp);

    if not startCopper then
        return 0;
    end

    return currentCopper - startCopper;
end

function Statistics:GetDailyGoalProgress(dailyGoal, currentCopper)
    if not dailyGoal or dailyGoal <= 0 then
        return nil;
    end

    local earnedToday = self:GetCopperEarnedSince(GetStartOfToday(), currentCopper);

    return {
        target = dailyGoal,
        earned = earnedToday,
        remaining = math.max(dailyGoal - earnedToday, 0);
        progress = math.min(earnedToday / dailyGoal, 1);
    };
end

function Statistics:GetTimeToAmount(currentCopper, targetCopper, rate)
    local copperDelta = targetCopper - currentCopper;

    if not rate or rate <= 0 then
        return nil;
    end

    if copperDelta <= 0 then
        return 0;
    end

    return copperDelta / rate;
end

function Statistics:GetTimeToGoal(currentCopper, goalCopper)
    if not goalCopper or goalCopper <= 0 then
        return nil;
    end

    local statistics = self:GetMoneyRate(STATISTICS_WINDOW);

    if not statistics then
        return nil;
    end

    return self:GetTimeToAmount(currentCopper, goalCopper, statistics.rate);
end
