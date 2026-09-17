local _, GoldPlanner = ...;

function GoldPlanner:ColorText(text, color)
    return string.format("|cff%s%s|r", color, text);
end

function GoldPlanner:Log(...)
    print(self:ColorText(self.name, self.COLORS.GOLD) .. ":", ...);
end

function GoldPlanner.TrimGold(copper)
    return math.floor(copper / 10000) * 10000;
end