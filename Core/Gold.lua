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

function GoldPlanner:GetWarbandCopper()
    return C_Bank.FetchDepositedMoney(Enum.BankType.Account) or 0;
end

function GoldPlanner:UpdateCharacterGold()
    local character = self:GetCharacter();

    character.copper = GetMoney();

    self:AddHistorySnapshot();
    self:AddTotalHistorySnapshot();
end

function GoldPlanner:UpdateWarbandGold()
    local copper = self:GetWarbandCopper();

    self.db.warband.copper = copper;

    self:AddWarbandHistorySnapshot();
    self:AddTotalHistorySnapshot();
end

function GoldPlanner:GetTotalCopper()
    local characterTotal = 0;

    for _, character in pairs(self.db.characters) do
        characterTotal = characterTotal + character.copper;
    end

    return characterTotal + self:GetWarbandCopper();
end