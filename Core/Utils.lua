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
    return math.floor(copper / 10000) * 10000;
end