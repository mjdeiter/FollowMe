# FollowMe.lua

A [MacroQuest](https://www.macroquest.org/) Lua script for EverQuest that periodically issues a follow/navigation command toward a designated "driver" character, with a small ImGui control panel.

## What it does

On a configurable interval, the script runs:

```
/e3bcg /nav id <your character's ID>
```

This is intended to be broadcast to your group/raid via `e3bcg` so that other toons re-navigate toward you (the driver) on a regular cadence.

## Usage

```
/lua run FollowMe
```

This opens a small **FollowMe** window with the following controls:

- **Interval slider** — how often (in seconds) the command is fired, from 1.0 to 30.0 seconds.
- **START / STOP** — toggles automatic firing on the configured interval.
- **Fire Once** — manually sends the command immediately, regardless of the timer or standby state.
- **Status text & progress bar** — shows whether the script is idle, running, fired, or in standby, and how far along the current interval is.

## Zone-based standby

The script can automatically pause itself while you're in certain zones (for example, hub zones like The Nexus, Plane of Knowledge, or Plane of Tranquility, where you typically don't need to be auto-navigating to a driver).

- **Standby in listed zones** checkbox — turns this feature on or off (on by default).
- **Add zone (short name)** — type a zone short name and click **Add** to add it to the standby list. Entries are lowercased and de-duplicated automatically.
- **Standby zones dropdown** — shows all configured standby zones. Select one and click **Remove Selected** to remove it.

While standby is active and you're in one of the listed zones:

- Automatic firing pauses.
- The status text shows `Standby (zone: <shortname>)`.
- The progress bar is replaced with a gray "Standby - zone excluded" indicator.
- **Fire Once** still works manually if you need to send the command anyway.

### Default standby zones

- `nexus` — The Nexus
- `poknowledge` — Plane of Knowledge
- `tranquility` — Plane of Tranquility

### Finding zone short names

To add your own zones, you need the zone's **short name** (the internal identifier MacroQuest/EverQuest uses, e.g. `poknowledge`, `nexus`, `tranquility`), not the display name.

A community-maintained reference list is available here:

**[Zone Short Names — RedGuides](https://www.redguides.com/docs/projects/everquest/general/zone-short-names/)**

> **Note:** That list is a *general* EverQuest zone short name reference and is **not specific to Project Lazarus**. Zone short names can differ between servers/emulators, especially for custom or modified zones.
>
> The most reliable way to get the definitive short name for a zone on Project Lazarus is to physically travel to that zone and run:
>
> ```
> /who all <YourCharacterName>
> ```
>
> This will display your character's current zone using the exact short name your server recognizes — use that value when adding the zone to FollowMe's standby list.

## Requirements

- [MacroQuest](https://www.macroquest.org/) (Next/Lua build)
- The `mq` and `ImGui` Lua modules (bundled with MacroQuest's Lua support)
- The `e3bcg` plugin/bot command set (e.g. via EQBC/E3) for the broadcast `/nav` command to work as intended

## Notes / Limitations

- The standby zone list is **not persisted** — it resets to the defaults above each time the script is reloaded. If you'd like the list to be saved across sessions, please open an issue or PR.

## License

MIT — see [LICENSE](LICENSE).

