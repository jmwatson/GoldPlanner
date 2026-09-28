local _, GoldPlanner = ...;

GoldPlanner.Data = GoldPlanner.Data or {};

local History = {};
GoldPlanner.Data.History = History;

local tinsert = table.insert;
local totalHistoryPending = false;

local TIMESTAMP = 1;
local COPPER = 2;

local WEEK = 604800;
local DAY = 86400;
local HOUR = 3600;

-- Only keep snapshots of the history the older it gets
local COMPACTION_WINDOWS = {
    { age = DAY, bucket = 0 },
    { age = WEEK, bucket = HOUR },
    { age = 90 * DAY, bucket = DAY },
    { age = math.huge, bucket = WEEK },
};

local function AddHistorySnapshot(history, copper)
    local lastSnapshot = history[#history];
    local snapshot = { time(), copper };

    -- Don't record enteries if nothing has changed
    if lastSnapshot and lastSnapshot[COPPER] == snapshot[COPPER] then
        return;
    end

    tinsert(history, snapshot);
end

local function CompactHistory(history, now)
    if #history < 30 then
        return history;
    end

    local compacted = {};
    local lastBucketSize = nil;
    local lastBucketKey = nil;

    for i = 1, #history do
        local snapshot = history[i];
        local age = now - snapshot[TIMESTAMP];
        local bucket = nil;

        for _, window in ipairs(COMPACTION_WINDOWS) do
            if age <= window.age then
                bucket = window.bucket;
                break;
            end
        end

        if bucket == 0 then
            tinsert(compacted, snapshot);
            lastBucketSize = nil;
            lastBucketKey = nil;
        elseif bucket then
            local bucketKey = math.floor(snapshot[TIMESTAMP] / bucket);

            if bucket == lastBucketSize and bucketKey == lastBucketKey then
                compacted[#compacted] = snapshot;
            else
                tinsert(compacted, snapshot);
                lastBucketSize = bucket;
                lastBucketKey = bucketKey;
            end
        end
    end

    return compacted;
end

function History:AddCharacterSnapshot()
    local character = GoldPlanner.Data.Gold:GetCharacter();
    AddHistorySnapshot(character.history, character.copper);
end

function History:AddWarbandSnapshot()
    AddHistorySnapshot(GoldPlanner.db.warband.history, GoldPlanner.db.warband.copper);
end

function History:AddTotalSnapshot()
    AddHistorySnapshot(GoldPlanner.db.totalHistory, GoldPlanner.Data.Gold:GetTotalCopper());
end

function History:GetTotal()
    return GoldPlanner.db.totalHistory;
end

function History:ScheduleTotalSnapshot()
    if totalHistoryPending then
        return;
    end

    totalHistoryPending = true;

    -- This happens at the end of the current frame to avoid multiple snapshots being added in the same frame
    C_Timer.After(0, function()
        totalHistoryPending = false;
        self:AddTotalSnapshot();
    end);
end

function History:CompactAllHistory()
    local now = time();
    local db = GoldPlanner.db;
    local lastCompaction = db.lastCompaction;

    if lastCompaction and (now - lastCompaction) < DAY then
        return;
    end

    for _, character in pairs(db.characters) do
        character.history = CompactHistory(character.history, now);
    end

    db.warband.history = CompactHistory(db.warband.history, now);
    db.totalHistory = CompactHistory(db.totalHistory, now);
    db.lastCompaction = now;

    GoldPlanner:Log("History compaction complete.")
end