# Patch notes

**Summary**
Many areas where getting flagged as dungeons, so I switched it down to specific dungeons, and then we can add them manually rather then tagging all caves/mines/keeps/forts, so everything should be unsealed after this update, Characters that logged out in a dungeon got flagged for deletion on the regen, I restored all the characters, if you are still missing a character open a support ticket and we will resolve it!

Also, seperate note players who are packrats and accumulating alot of items apprently there is more optimizations to be done with inventory system, so I am working on making it more efficient so it doesnt slow down inventory updates so stay tuned!

thank you all for your patience and understanding as we continue to improve!

## Changes
- Fixed issue with farming resources not respawning
- Fixed several activators to respawn if values changed and/or clamped
- Fixed an issue with shrine buffs not sticking on relog
- Fixed an issue with alchemy crafting wrong effects/potency
- Fixed an issue with movement getting locked and not able to unstick
- Fixed an issue where buffs/debuffs not restoring on reboot
- Fixed several issues with enchantment pipeline (I STILL NEED THIS TESTED AND DIAGNOSTICS SENT TO ME PLZ)
- Reduced combat lock timers after swings
- Added milk jugs as harvestable items at farms for farmers
- Added grain mill to dawnstar for the salt
- Added xp for enchant/disenchanting items
- Sawmills are now operational, will need some feedback on this
- Removed floating tree south of labyrinthian
- Returned kilns back (we will work on special resources for holds individually with each hold)
- Reworked what clasifys as a dungeon to LocTypeDungeon, Cave, NordicRuin, DwemerRuin, DraugrCrypt, VampireLair, and WarlockLair (no more keeps/forts)
- Optimized inventory data over the wire, help with people who have big inventorys getting delayed
- Health regen only recovers when sitting instead of out of combat, with this I increased the regen rate a bit