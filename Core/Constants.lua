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
    EMPTY_STRING = "",

    SLASH_COMMAND = "/goldplanner",
    SLASH_COMMAND_SHORT = "/gp",

    ADDON_TITLE = "Gold Planner",

    CHARACTER_GOLD = "Character",
    WARBAND_GOLD = "Warband",
    TOTAL_GOLD = "Total",

    GOAL = "Goal",
    REMAINING = "Remaining",
    PROGRESS = "Progress",
    NO_GOAL = "No goal set",

    RATE = "Rate",
    TIME_TO_GOAL = "Time to Goal",
    DAILY_GOAL = "Daily Goal",
    NO_DEADLINE = "No deadline set",
    NOT_ENOUGH_DATA = "Not enough data",
    UNAVAILABLE = "Unavailable",
    REACHED = "Reached",
};