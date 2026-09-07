local _, GoldPlanner = ...;
local tinsert = table.insert;

function GoldPlanner:AddHistorySnapshot()
    local character = self:GetCharacter();
    local history = character.history;
    local snapshot = {
        timestamp = time(),
        copper = character.copper,
    };
    local lastSnapshot = history[#history];

    -- Don't record enteries if nothing has changed
    if lastSnapshot and lastSnapshot.copper == snapshot.copper then
        return;
    end

    tinsert(history, snapshot);
end

function GoldPlanner:AddWarbandHistorySnapshot(copper)
    if not copper then
        return;
    end

    local history = self.db.warband.history;
    local lastSnapshot = history[#history];
    local snapshot = {
        timestamp = time(),
        copper = copper,
    };

    -- Don't record enteries if nothing has changed
    if lastSnapshot and lastSnapshot.copper == snapshot.copper then
        return;
    end

    tinsert(history, snapshot);
end

function GoldPlanner:AddTotalHistorySnapshot()
    local totalCopper = self:GetTotalCopper();
    local history = self.db.totalHistory;
    local lastSnapshot = history[#history];
    local snapshot = {
        timestamp = time(),
        copper = totalCopper,
    };

    -- Don't record enteries if nothing has changed
    if lastSnapshot and lastSnapshot.copper == snapshot.copper then
        return;
    end

    tinsert(history, snapshot);
end