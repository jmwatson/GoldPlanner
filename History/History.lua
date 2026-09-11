local _, GoldPlanner = ...;
local tinsert = table.insert;
local totalHistoryPending = false;

local COPPER = 2;

local function AddHistorySnapshot(history, copper)
    local lastSnapshot = history[#history];
    local snapshot = { time(), copper };

    -- Don't record enteries if nothing has changed
    if lastSnapshot and lastSnapshot[COPPER] == snapshot[COPPER] then
        return;
    end

    tinsert(history, snapshot);
end

function GoldPlanner:AddCharacterHistorySnapshot()
    local character = self:GetCharacter();
    AddHistorySnapshot(character.history, character.copper);
end

function GoldPlanner:AddWarbandHistorySnapshot()
    AddHistorySnapshot(self.db.warband.history, self.db.warband.copper);
end

function GoldPlanner:AddTotalHistorySnapshot()
    AddHistorySnapshot(self.db.totalHistory, self:GetTotalCopper());
end

function GoldPlanner:ScheduleTotalHistorySnapshot()
    if totalHistoryPending then
        return;
    end

    totalHistoryPending = true;

    -- This happens at the end of the current frame to avoid multiple snapshots being added in the same frame
    C_Timer.After(0, function()
        totalHistoryPending = false;
        self:AddTotalHistorySnapshot();
    end);
end