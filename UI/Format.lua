local _, GoldPlanner = ...;

GoldPlanner.UI = GoldPlanner.UI or {};

local Format = {};
GoldPlanner.UI.Format = Format;

local STRINGS = GoldPlanner.STRINGS;
local trim = GoldPlanner.Utils.TrimGold;

local DAY = 86400;
local HOUR = 3600;
local MINUTE = 60;

function Format.Duration(seconds)
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

function Format.Rate(hourlyCopper, shouldTrim)
    if not hourlyCopper then
        return string.format("%s: %s", STRINGS.RATE, STRINGS.NOT_ENOUGH_DATA);
    end

    local value = shouldTrim and trim(hourlyCopper) or hourlyCopper;

    return string.format("%s: %s/hour", STRINGS.RATE, GetMoneyString(value, true));
end

function Format.TimeToGoal(goalCopper, seconds)
    if goalCopper <= 0 then
        return string.format("%s: %s", STRINGS.TIME_TO_GOAL, STRINGS.NO_GOAL);
    elseif not seconds then
        return string.format("%s: %s", STRINGS.TIME_TO_GOAL, STRINGS.UNAVAILABLE);
    elseif seconds == 0 then
        return string.format("%s: %s", STRINGS.TIME_TO_GOAL, STRINGS.REACHED);
    end

    return string.format("%s: %s", STRINGS.TIME_TO_GOAL, Format.Duration(seconds));
end

function Format.DailyGoal(daily)
    if not daily then
        return string.format("%s: %s", STRINGS.DAILY_GOAL, STRINGS.NO_DEADLINE);
    end

    return string.format("%s: %s / %s today",
        STRINGS.DAILY_GOAL,
        GetMoneyString(trim(daily.earned), true),
        GetMoneyString(trim(daily.target), true));
end
