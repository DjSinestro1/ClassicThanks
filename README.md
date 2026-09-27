# ClassicThanks

Automatic friendly thank-you messages for **Blizzard WoW Classic Era 1.15.9**, including Hardcore on that client. This initial beta has mocked-API tests, but still needs an in-game test. It is not the old 1.12 OctoWoW/Turtle addon, and other Classic expansions are not yet validated.

Default: public **SAY**. Optional: private **WHISPER** to the player who buffed you. Both use 28 rotating English-language replies with no consecutive repeat; custom messages are supported. Slang-inspired replies include British/Cockney, US street and retro jive-style, Australian, New Zealand, South African, Irish, and Canadian expressions. They are playful phrases, not claims to represent everyone's dialect.

**Outdoor SAY needs player input.** When a buff qualifies, type `/ct send` at the local prompt, then press Enter to submit the prepared message. Drafts expire after 30 seconds. Say is attempted automatically inside instances where allowed. Whisper remains automatic. This respects Blizzard's restrictions on outdoor automated public chat.

Only buffs lasting **strictly longer than 120 seconds** qualify. Self-buffs, NPC buffs, short heals-over-time, and missing/zero durations are ignored. A combat-log aura application/refresh identifies the caster; the player's helpful-aura list verifies duration. Existing buffs on login do not trigger thanks. Detection pauses for two seconds after entering the world. No target switching, combat actions, or combat-log text parsing.

One-second send delay after duration verification, 60-second per-player cooldown, and a global three-second chat limit. Extra simultaneous messages are dropped. Channel changes do not reset cooldowns. WoW may restrict automatic chat; counters show requests, not confirmed delivery.

## Install and commands

Extract the `ClassicThanks` folder into `_classic_era_/Interface/AddOns`, restart the client, and enable it. Do not run another auto-thanks addon alongside it.

- `/ct channel say` - public thanks (default).
- `/ct channel whisper` - private thanks to the caster.
- `/ct on` / `/ct off` - enable or disable.
- `/ct status` - selected channel and diagnostics.
- `/ct send` - open a pending outdoor say draft; press Enter to submit.
- `/ct preview` - local preview; sends nothing.
- `/ct cooldown 60` - cooldown of 30-3600 seconds.
- `/ct groups on|off` - thanks while grouped (default on).
- `/ct message Thanks for %s!` - custom message; `%s` inserts the buff name.
- `/ct message random` - restore all 28 replies.

`/classicthanks` is an alias. Settings persist across reloads.

## Quick test

Wait two seconds after login. Have another player give you a buff longer than two minutes. Outdoors, expect a local prompt after about one second; type `/ct send` and press Enter. Switch to whisper, wait at least 60 seconds, and ask for a refresh; expect an automatic private reply. Renew, self-buffs, duplicate events, and reloads must not generate thanks.

Source and downloads: https://github.com/DjSinestro1/ClassicThanks

All rights reserved.
