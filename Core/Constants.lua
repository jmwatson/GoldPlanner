local _, GoldPlanner = ...;

GoldPlanner.EVENTS = {
    ADDON_LOADED = "ADDON_LOADED",
    PLAYER_MONEY = "PLAYER_MONEY",
};

GoldPlanner.COLORS = {
    GOLD = "FFD100",
    SILVER = "C0C0C0",
    COPPER = "B87333",
};

function GoldPlanner:ColorizeText(text, color)
    return string.format("|cff%s%s|r", color, text);
end