local _, GoldPlanner = ...;

GoldPlanner.Data = GoldPlanner.Data or {};

local History = {};
GoldPlanner.Data.History = History;

local tinsert = table.insert;
local totalHistoryPending = false;
local totalSource = nil;

local TIMESTAMP = 1;
local COPPER = 2;

local WEEK = 604800;
local DAY = 86400;
local HOUR = 3600;

local EVENTS = GoldPlanner.EVENTS;

-- Only keep snapshots of the history the older it gets
local COMPACTION_WINDOWS = {
    { age = DAY, bucket = 0 },
    { age = WEEK, bucket = HOUR },
    { age = 90 * DAY, bucket = DAY },
    { age = math.huge, bucket = WEEK },
};

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

    wipe(history);

    for i = 1, #compacted do
        history[i] = compacted[i];
    end
end

function History:Record(history, copper)
    local lastSnapshot = history[#history];
    local snapshot = { time(), copper };

    -- Don't record enteries if nothing has changed
    if lastSnapshot and lastSnapshot[COPPER] == snapshot[COPPER] then
        return;
    end

    tinsert(history, snapshot);
end

function History:SetTotalSource(provider)
    totalSource = provider;
end

function History:RequestTotalSnapshot()
    if totalHistoryPending or not totalSource then
        return;
    end

    totalHistoryPending = true;

    -- This happens at the end of the current frame to avoid multiple snapshots being added in the same frame
    C_Timer.After(0, function()
        totalHistoryPending = false;
        self:Record(GoldPlanner.db.totalHistory, totalSource());
        EventRegistry:TriggerEvent(GoldPlanner.EVENTS.HISTORY_TOTAL_UPDATED);
    end);
end

function History:CompactAll(characters, warband)
    local now = time();
    local db = GoldPlanner.db;
    local lastCompaction = db.lastCompaction;

    if lastCompaction and (now - lastCompaction) < DAY then
        return;
    end

    for _, character in pairs(characters) do
        CompactHistory(character.history, now);
    end

    CompactHistory(warband.history, now);
    CompactHistory(db.totalHistory, now);
    db.lastCompaction = now;

    GoldPlanner.Utils.Log("History compaction complete.")
end

function History:GetCopperAt(timestamp)
    local history = GoldPlanner.db.totalHistory;
    local first = history[1];

    if not first then
        return nil;
    end

    if timestamp <= first[TIMESTAMP] then
        return first[COPPER];
    end

    for i = 1, #history - 1 do
        first = history[i];
        local second = history[i + 1];

        if first[TIMESTAMP] <= timestamp and timestamp <= second[TIMESTAMP] then
            local span = second[TIMESTAMP] - first[TIMESTAMP];

            if span <= 0 then
                return first[COPPER];
            end

            -- Interpolate between the two snapshots due to compaction
            local progress = (timestamp - first[TIMESTAMP]) / span;
            return first[COPPER] + (second[COPPER] - first[COPPER]) * progress;
        end
    end

    return history[#history][COPPER];
end

function History:GetWindow(windowSeconds)
    local history = GoldPlanner.db.totalHistory;
    local count = #history;

    if count < 2 then
        return nil;
    end

    local latest = history[count];
    local cutoff = latest[TIMESTAMP] - windowSeconds;
    local oldest = nil;

    -- Walk history backwards to find the oldest snapshot within the window,
    -- or the oldest snapshot before the cutoff if none are within the window
    for i = count - 1, 1, -1 do
        local snapshot = history[i];

        if snapshot[TIMESTAMP] < latest[TIMESTAMP] then
            if not oldest or snapshot[TIMESTAMP] >= cutoff then
                oldest = snapshot;
            else
                break;
            end
        end
    end

    if not oldest then
        return nil;
    end

    return {
        startTime = oldest[TIMESTAMP],
        startCopper = oldest[COPPER],
        endTime = latest[TIMESTAMP],
        endCopper = latest[COPPER],
    };
end

function History:RecordCharacterSnapshot(copper)
    self:Record(GoldPlanner.Data.Account:GetCharacter().history, copper);
    self:RequestTotalSnapshot();
end

function History:RecordWarbandSnapshot(copper)
    self:Record(GoldPlanner.Data.Account:GetWarband().history, copper);
    self:RequestTotalSnapshot();
end

EventRegistry:RegisterCallback(EVENTS.CHARACTER_COPPER_UPDATED, History.RecordCharacterSnapshot, History);
EventRegistry:RegisterCallback(EVENTS.WARBAND_COPPER_UPDATED, History.RecordWarbandSnapshot, History);
