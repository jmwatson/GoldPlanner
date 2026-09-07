local _, GoldPlanner = ...;

GoldPlanner.EVENTS = {
    ADDON_LOADED = "ADDON_LOADED",
    PLAYER_ENTERING_WORLD = "PLAYER_ENTERING_WORLD",
    PLAYER_MONEY = "PLAYER_MONEY",
    BANKFRAME_OPENED = "BANKFRAME_OPENED",
    BANKFRAME_CLOSED = "BANKFRAME_CLOSED",
    ACCOUNT_MONEY = "ACCOUNT_MONEY",
};

GoldPlanner.COLORS = {
    GOLD = "FFD100",
    SILVER = "C0C0C0",
    COPPER = "B87333",
};

GoldPlanner.STRINGS = {
    SLASH_COMMAND = "/goldplanner",
    SLASH_COMMAND_SHORT = "/gp",
};

function GoldPlanner:ColorizeText(text, color)
    return string.format("|cff%s%s|r", color, text);
end

function GoldPlanner:Log(...)
    print(self:ColorizeText(self.name, self.COLORS.GOLD) .. ":", ...);
end