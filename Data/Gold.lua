local _, GoldPlanner = ...;

GoldPlanner.Data = GoldPlanner.Data or {};

local Gold = {};
GoldPlanner.Data.Gold = Gold;

local Account = GoldPlanner.Data.Account;
local EVENTS = GoldPlanner.EVENTS;

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
    if not C_Bank.CanViewBank(Enum.BankType.Account) then
        return nil;
    end

    local warband = Account:GetWarband();
    warband.copper = C_Bank.FetchDepositedMoney(Enum.BankType.Account);

    return warband.copper;
end

function Gold:OnPlayerMoney()
    EventRegistry:TriggerEvent(EVENTS.CHARACTER_COPPER_UPDATED, self:UpdateCharacterCopper());
end

function Gold:OnAccountMoney()
    local copper = self:UpdateWarbandCopper();

    if copper ~= nil then
        EventRegistry:TriggerEvent(EVENTS.WARBAND_COPPER_UPDATED, copper);
    end
end

function Gold:OnEnteringWorld()
    self:OnPlayerMoney();
    self:OnAccountMoney();
end

function Gold:Initialize()
    if self.initialized then
        return;
    end

    self.initialized = true;

    GoldPlanner.Data.History:SetTotalSource(function()
        return self:GetTotalCopper();
    end);

    EventRegistry:RegisterFrameEventAndCallback(EVENTS.PLAYER_MONEY, self.OnPlayerMoney, self);
    EventRegistry:RegisterFrameEventAndCallback(EVENTS.ACCOUNT_MONEY, self.OnAccountMoney, self);
    EventRegistry:RegisterFrameEventAndCallback(EVENTS.PLAYER_ENTERING_WORLD, self.OnEnteringWorld, self);
end

EventRegistry:RegisterFrameEventAndCallback(EVENTS.PLAYER_LOGIN, Gold.Initialize, Gold);
