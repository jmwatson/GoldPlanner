local _, GoldPlanner = ...;

GoldPlanner.UI = GoldPlanner.UI or {};

local Format = {};
GoldPlanner.UI.Format = Format;

local STRINGS = GoldPlanner.STRINGS;
local trim = GoldPlanner.Utils.TrimGold;

local DAY = 86400;
local HOUR = 3600;
local MINUTE = 60;

local ARROW_UP = "|TInterface\\AddOns\\GoldPlanner\\Assets\\Up:8:8|t";
local ARROW_DOWN = "|TInterface\\AddOns\\GoldPlanner\\Assets\\Down:8:8|t";

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

    local sign = hourlyCopper < 0 and "-" or "";
    local value = math.abs(hourlyCopper);
    value = shouldTrim and trim(value) or value;

    return string.format("%s: %s%s / hour %s",
        STRINGS.RATE,
        sign,
        GetMoneyString(value, true),
        hourlyCopper < 0 and ARROW_DOWN or ARROW_UP);
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
