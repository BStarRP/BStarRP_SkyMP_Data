# Patch notes

**Summary**
Just gonna keep cookin here.... also I recompiled Precision mod from source to see if I can customize it enough to fix combat sync!  Will be testing it after this update!

## Changes
- Fixed more syncing issues when lumber mill runs animations
- Fixed an issue where alpha was being applied frequently causing a slight flash on local player
- Fixed an issue with disenchant/enchanting not going to server and updating the item in real time
- Fixed an issue with holdstones not opening
- Fixed an issue with holdstones not setting ranks
- Fixed an issue with summons not despawning
- Fixed an issue with summons not being friendly
- Fixed an issue with interaction menu not closing when you load through a door
- Fixed an issue with puzzles/levers not fully syncing in dunegons, now the door should trigger for all people + anyone can do the puzzle + it should stay triggered on relog
- Fixed crossbows not giving experience
- Improved lock syncing more, interior/exterior doors share lock states, server always syncs lock states to all client + holdstone or /setlock admin command overwrite native espm lock states
- Improved syncing of health/mana/stamina bars on remote npcs/players
- Implemented necromancy system, raising the dead follows a similar system that conjures do, set friendly, server side hosted hand-off to player
- Updated so changes to standing stones like the Tower giving +10 lockpicking and Shadow giving +10 sneaking
- Updated skill system to support bonus's to skills not just for racials but other systems like buffs/jobs and so on
- Optimized performance when going through doors/teleporting
- Finished more spells Turn Undead, Banish, Light, Detect Life, Slow Time is relative: nearby listeners get slow at -35% SpeedMult (not global time scale)
- Modified WIChangeLocation03 (challenger quest) so it can never start
- Added cooking pot, decorative breweries back into the Windpeak Inn in Dawnstar 
- Changed recipes for the guard cloaks from Cloaks of Skyrim to require the permission writ to be crafted
- Renamed items with "stormcloak" in their name to "eastmarch"
- Hid some map markers that were visible from the start, now only cities should be visible
- Markarth additions
- Made Imperial armor craftable 
- Made vigilant armors craftable (+ silver swords and stendarr amulet)
- Markarth Side additions
- Falkreath additions
- Changed Shadow stone to provide +10 Sneak
- Changed Tower stone to provide +10 Lockpicking, turned standing stone back into an activator
- Removed the stupid locked door in Rannveigs Fast so staff dont have to go unlock it every 3 hours because someone has fallen in the pit and cant get out 
- Re-added Morthal Holdstone
- Moved snowberries to herbalism =)

