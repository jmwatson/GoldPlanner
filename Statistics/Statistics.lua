local _, GoldPlanner = ...;

GoldPlanner.Data = GoldPlanner.Data or {};

local Statistics = {};
GoldPlanner.Data.Statistics = Statistics;

local DAY = 86400;
local HOUR = 3600;
local MINUTE = 60;
local STATISTICS_WINDOW = HOUR;

local TIMESTAMP = 1;
local COPPER = 2;

local function GetStartOfToday()
    local today = date("*t");
    today.hour = 0;
    today.min = 0;
    today.sec = 0;
    return time(today);
end

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

local function GetCopperAt(history, timestamp)
    local first = history[1]

    if timestamp <= first[TIMESTAMP] then
        return first[COPPER];
    end

    for i = 1, #history - 1 do
        first = history[i];
        local second = history[i + 1];

        if first[TIMESTAMP] <= timestamp and timestamp <= second[TIMESTAMP] then
            local span = second[TIMESTAMP] - first[TIMESTAMP];

            if span <= 0 then
                return first[COPPER];
            end

            local progress = (timestamp - first[TIMESTAMP]) / span;
            return first[COPPER] + (second[COPPER] - first[COPPER]) * progress;
        end
    end

    return history[#history][COPPER];
end

function Statistics:GetMoneyRate(windowSeconds)
    local history = GoldPlanner.Data.History:GetTotal();

    -- Not enough history to calculate a rate
    if #history < 2 then
        return nil;
    end

    local latest = history[#history];
    local cutoff = latest[TIMESTAMP] - windowSeconds;
    local oldest = nil;

    for i = 1, #history do
        local snapshot = history[i];

        if snapshot[TIMESTAMP] >= cutoff then
            oldest = snapshot;
            break;
        end
    end

    if not oldest then
        oldest = history[1];
    end

    local elapsed = latest[TIMESTAMP] - oldest[TIMESTAMP];

    -- Another window check to make sure we don't divide by zero
    if elapsed <= 0 then
        return nil;
    end

    local copperDelta = latest[COPPER] - oldest[COPPER];

    return {
        copperDelta = copperDelta,
        elapsed = elapsed,
        rate = copperDelta / elapsed,
    };
end

function Statistics:GetCopperEarnedSince(timestamp)
    local history = GoldPlanner.Data.History:GetTotal();

    if #history < 1 then
        return 0;
    end

    local startCopper = GetCopperAt(history, timestamp)
    return GoldPlanner.Data.Gold:GetTotalCopper() - startCopper;
end

function Statistics:GetDailyGoalProgress()
    local dailyGoal = GoldPlanner.Data.Goal:GetDaily();

    if not dailyGoal or dailyGoal <= 0 then
        return nil;
    end

    local earnedToday = self:GetCopperEarnedSince(GetStartOfToday());

    return {
        target = dailyGoal,
        earned = earnedToday,
        remaining = math.max(dailyGoal - earnedToday, 0);
        progress = math.min(earnedToday / dailyGoal, 1);
    };
end

function Statistics:GetDailyGoalDisplay()
    local trim = GoldPlanner.TrimGold;
    local daily = self:GetDailyGoalProgress();

    if not daily then
        return nil;
    end

    local earned = trim(daily.earned);
    local target = trim(daily.target);

    return string.format("%s / %s today", GetMoneyString(earned, true), GetMoneyString(target, true));
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

function Statistics:GetMoneyRateDisplay(trim)
    local statistics = self:GetMoneyRate(STATISTICS_WINDOW);

    if not statistics then
        return nil;
    end

    local windowRate = statistics.rate * STATISTICS_WINDOW;

    if trim then
        return GetMoneyString(trim(windowRate), true);
    else
        return GetMoneyString(windowRate, true);
    end
end

function Statistics:GetTimeToGoalDisplay()
    local goal = GoldPlanner.Data.Goal:Get();
    local totalCopper = GoldPlanner.Data.Gold:GetTotalCopper();
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