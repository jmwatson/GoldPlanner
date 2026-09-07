local _, GoldPlanner = ...;

function GoldPlanner:GetMoneyRate(windowSeconds)
    local history = self.db.totalHistory;

    -- Not enough history to calculate a rate
    if #history < 2 then
        return nil;
    end

    local latest = history[#history];
    local cutoff = latest.timestamp - windowSeconds;
    local oldest = nil;

    for i = 1, #history do
        local snapshot = history[i];

        if snapshot.timestamp >= cutoff then
            oldest = snapshot;
            break;
        end
    end

    if not oldest then
        oldest = history[1];
    end

    local elapsed = latest.timestamp - oldest.timestamp;

    -- Another window check to make sure we don't divide by zero
    if elapsed <= 0 then
        return nil;
    end

    local copperDelta = latest.copper - oldest.copper;

    return {
        copperDelta = copperDelta,
        elapsed = elapsed,
        rate = copperDelta / elapsed,
    };
end