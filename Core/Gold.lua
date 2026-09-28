local _, GoldPlanner = ...;

GoldPlanner.Data = GoldPlanner.Data or {};

local Gold = {};
GoldPlanner.Data.Gold = Gold;

local function GetCharacterKey()
    local name = UnitName("player");
    local realm = GetRealmName();

    return name .. "-" .. realm;
end

function Gold:GetCharacter()
    local key = GetCharacterKey();

    if not GoldPlanner.db.characters[key] then
        GoldPlanner.db.characters[key] = {
            name = UnitName("player"),
            realm = GetRealmName(),
            copper = 0,
            history = {},
        };
    end

    return GoldPlanner.db.characters[key];
end

function Gold:GetWarband()
    return GoldPlanner.db.warband;
end

function Gold:GetTotalCopper()
    local copperTotal = GoldPlanner.db.warband.copper;

    for _, character in pairs(GoldPlanner.db.characters) do
        copperTotal = copperTotal + character.copper;
    end

    return copperTotal;
end

function Gold:UpdateCharacterCopper()
    local character = self:GetCharacter();

    character.copper = GetMoney();

    GoldPlanner:AddCharacterHistorySnapshot();
    GoldPlanner:ScheduleTotalHistorySnapshot();
end

function Gold:UpdateWarbandCopper()
    GoldPlanner.db.warband.copper = C_Bank.FetchDepositedMoney(Enum.BankType.Account);

    GoldPlanner:AddWarbandHistorySnapshot();
    GoldPlanner:ScheduleTotalHistorySnapshot();
end