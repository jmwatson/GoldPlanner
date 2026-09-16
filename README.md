# Gold Planner

Plan, track, and reach your gold goals. Gold Planner tracks your gold across all characters and your Warband bank, shows your progress toward a goal, and estimates how fast you're earning.

## Slash Commands

The base command is `/goldplanner`, with `/gp` as a shorthand. Both work identically everywhere below.

### Dashboard

| Command | Effect |
|---|---|
| `/gp` | Toggle the main dashboard window open/closed. |

### Goal

| Command | Effect |
|---|---|
| `/gp goal <amount>` | Set your gold goal, in gold (e.g. `/gp goal 5000` sets a 5,000g goal). |
| `/gp goal <amount> <days>` | Set a goal *and* a deadline, `<days>` from now (e.g. `/gp goal 5000 30` sets a 5,000g goal due in 30 days). Once a deadline is set, the Dashboard shows the average gold/day needed to hit it on time, recalculated live as your progress changes. |

### Progress Bar

The progress bar is a small, always-visible, draggable bar (separate from the Dashboard) showing progress toward your goal.

| Command | Effect |
|---|---|
| `/gp bar lock` | Disable dragging, so the bar can't be bumped accidentally. |
| `/gp bar unlock` | Re-enable dragging. |
| `/gp bar show` | Show the progress bar. |
| `/gp bar hide` | Hide the progress bar. |
| `/gp bar size <width> <height>` | Resize the bar, in pixels (e.g. `/gp bar size 400 20`). |
| `/gp bar color <r> <g> <b>` | Set the bar's fill color. Each of `r`, `g`, `b` is a number from `0` to `1` (e.g. `/gp bar color 0.1 0.85 0.1` for green). |
| `/gp bar bordercolor <r> <g> <b>` | Set the bar's border color, same `0`–`1` format as above. |
| `/gp bar reset` | Reset the bar's position, size, and colors back to their defaults. |

Dragging the bar (right-click and drag) also saves its new position automatically — no command needed for that.

### Settings

| Command | Effect |
|---|---|
| `/gp settings` | Open Gold Planner's panel in the game's Settings window (Options → AddOns). Goal and deadline are on the main page; progress bar options are in a Progress Bar subcategory. |

## Notes

- Gold amounts in commands are always plain gold numbers (no need to add zeros for silver/copper) — `/gp goal 5000` means 5,000 gold, not 5,000 copper.
- Color values are `0`–`1`, not `0`–`255` — this matches how WoW's own UI color pickers work internally.
- Progress bar settings (position, size, colors, lock state), goal, deadline, and gold history are all saved account-wide, in a single `GoldPlannerDB` — the same settings and progress bar position will show up on every character.