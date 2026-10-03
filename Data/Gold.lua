local _, GoldPlanner = ...;

GoldPlanner.Data = GoldPlanner.Data or {};

local Gold = {};
GoldPlanner.Data.Gold = Gold;

local Account = GoldPlanner.Data.Account;

function Gold:GetCharacterCopper()
    local character = Account:FindCharacter();
    return character and character.copper or 0;
end

function Gold:GetWarbandCopper()
    return Account:GetWarband().copper;
end

function Gold:GetTotalCopper()
    local copperTotal = Account:GetWarband().copper;

    for _, character in pairs(Account:GetCharacters()) do
        copperTotal = copperTotal + character.copper;
    end

    return copperTotal;
end

function Gold:UpdateCharacterCopper()
    local character = Account:GetCharacter();

    character.copper = GetMoney();
    
    return character.copper;
end

function Gold:UpdateWarbandCopper()
    local warband = Account:GetWarband();

    warband.copper = C_Bank.FetchDepositedMoney(Enum.BankType.Account);

    return warband.copper;
end
