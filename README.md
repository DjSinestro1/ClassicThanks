# ClassicThanks

Automatic private thank-you whispers for **Blizzard WoW Classic Era 1.15.9**, including Hardcore on that client. Initial beta by Sinestro; other Classic expansions are not yet validated.

When another player gives you a helpful buff lasting **strictly longer than two minutes**, ClassicThanks whispers one of 28 friendly replies. No manual send step is required. Upgrading migrates earlier SAY settings to WHISPER.

Self-buffs, NPC buffs, short heals-over-time, and missing/zero durations are ignored. The combat log identifies the caster; the player's helpful-aura list verifies duration. Existing buffs on login do not trigger thanks. Detection pauses for two seconds after entering the world.

Replies include British/Cockney, US street and retro jive-style, Australian, New Zealand, South African, Irish, and Canadian expressions. No consecutive random repeats. Custom messages remain supported.

The delay is about one second after duration verification, with a 60-second per-player cooldown and three-second global limit. Extra simultaneous thanks are dropped. WoW may still restrict chat; counters show API requests, not confirmed delivery.

## Install and commands

Extract `ClassicThanks` into `_classic_era_/Interface/AddOns`, restart the client, and enable the addon. Do not run another auto-thanks addon alongside it.

- `/ct on` / `/ct off` - enable or disable.
- `/ct status` - settings and diagnostics.
- `/ct preview` - local preview; sends nothing.
- `/ct cooldown 60` - 30-3600 seconds.
- `/ct groups on|off` - thanks while grouped (default on).
- `/ct message Thanks for %s!` - custom message; `%s` inserts the buff name.
- `/ct message random` - restore all 28 replies.

`/classicthanks` is an alias. Settings persist across reloads. This version only sends whispers; old channel commands cannot reenable say.

## Test

Wait two seconds after login. Ask another player for a buff longer than two minutes. Expect an automatic private reply after about one second, and no repeat within 60 seconds. Renew, self-buffs, duplicate events, and reloads must not generate thanks.

Mocked tests cover both modern and legacy Classic aura APIs. In-game validation is still needed. Run `lua5.1 tests/test.lua` from the repository root; `build.ps1` packages the addon.

Source and downloads: https://github.com/DjSinestro1/ClassicThanks

All rights reserved.
