local _, GoldPlanner = ...;

GoldPlanner.Data = GoldPlanner.Data or {};

local Account = {};
GoldPlanner.Data.Account = Account;

local function GetCharacterKey()
    local name = UnitName("player");
    local realm = GetRealmName();

    return name .. "-" .. realm;
end

-- Returns nil if the character does not exist in the database
function Account:FindCharacter()
    return GoldPlanner.db.characters[GetCharacterKey()];
end

-- Ensures that the character exists in the database and returns it
function Account:GetCharacter()
    local key = GetCharacterKey();
    local characters = self:GetCharacters();

    if not characters[key] then
        characters[key] = {
            name = UnitName("player"),
            realm = GetRealmName(),
            copper = 0,
            history = {},
        };
    end

    return characters[key];
end

function Account:GetCharacters()
    return GoldPlanner.db.characters;
end

function Account:GetWarband()
    return GoldPlanner.db.warband;
end

function Account:GetAllHistories()
    local histories = {};

    for _, character in pairs(self:GetCharacters()) do
        table.insert(histories, character.history);
    end

    table.insert(histories, self:GetWarband().history);

    return histories;
end
