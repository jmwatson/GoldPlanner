local _, GoldPlanner = ...;

local Utils = {};
GoldPlanner.Utils = Utils;

function Utils.ColorText(text, color)
    return string.format("|cff%s%s|r", color, text);
end

function Utils.Log(...)
    print(Utils.ColorText(GoldPlanner.name, GoldPlanner.COLORS.GOLD) .. ":", ...);
end

function Utils.TrimGold(copper)
    local sign = copper < 0 and -1 or 1;
    return sign * math.floor(math.abs(copper) / 10000) * 10000;
end

function Utils.GetStartOfDay(day)
    day.hour = 0;
    day.min = 0;
    day.sec = 0;
    return time(day);
end