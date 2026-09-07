local _, GoldPlanner = ...;

function GoldPlanner:GetCharacterKey()
    local name = UnitName("player");
    local realm = GetRealmName();

    return name .. "-" .. realm;
end

function GoldPlanner:GetCharacter()
    local key = self:GetCharacterKey();

    if not self.db.characters[key] then
        self.db.characters[key] = {
            name = UnitName("player"),
            realm = GetRealmName(),
            copper = 0,
            history = {},
        };
    end

    return self.db.characters[key];
end

function GoldPlanner:UpdateCharacterCopper()
    local character = self:GetCharacter();

    character.copper = GetMoney();

    self:AddCharacterHistorySnapshot();
    self:ScheduleTotalHistorySnapshot();
end

function GoldPlanner:UpdateWarbandCopper()
    self.db.warband.copper = C_Bank.FetchDepositedMoney(Enum.BankType.Account);

    self:AddWarbandHistorySnapshot();
    self:ScheduleTotalHistorySnapshot();
end

function GoldPlanner:GetTotalCopper()
    local copperTotal = self.db.warband.copper;

    for _, character in pairs(self.db.characters) do
        copperTotal = copperTotal + character.copper;
    end

    return copperTotal;
end