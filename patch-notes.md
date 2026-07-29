# Patch notes

**Summary**
So a big change here is all containers in the world now wont recycle with loot unless they are emptied, unless they in a dungeon and the dungeon seals and resets!  

The work we do with conjuration summons will go along ways for an animal taming system coming soon!

Also, I'm constantly tweaking and taking feedback, it was mentioned to spread out several perks gained from skills to unlock every 10 levels, to make leveling feel a bit more rewarding without big gaps between tiers, so I went through all the skills that had enough perks and re-tiered them!

Last but not least, I will keep finishing syncing of magic effects, we have 100's so I will try to squeeze a few in every couple of updates and eventually we will have all spells synced! This takes time, we are essentially rebuilding skyrim entirely to work over the network, but we making amazing progress!

## Changes
- Fixed an issue with new Comfort buff not triggering near fires
- Fixed an issue with concentration damage spels (i.e. sparks) applying side effect hostile damage causing insta death
- Fixed another issue with how animals are classified for hunting
- Fixed rank selection dropdown for holds
- Fixed an issue with idle animations and going into first person mode causing no clip, 3rd person forced during idle animations
- Fixed an issue where speed multipliers (buffs/debuffs) wernt updating and applying like with travelers backpack
- Fixed talking while in a trade window
- Fixed an issue with enchantment breakdown not working
- Fixed an issue with satchels giving double the carry weight
- Fixed an issue with arrows only allowing removing 1 at a time on stacks over 1000
- Updating containers so when items are added to it it cancels cooldown, proceeds if containers are fully emptied (unless in dungeons)
- Updated conjures aka summons to always teleport when you change areas, will set as a follower localy and stay hosted by you when logged in
- Updated Scenes to support 3hrs and 24hrs, added more colors, and 3 sizes
- Updated skill perk progression, to unlock every +10 levels instead of +20 levels on skills that permit
- Updated locks to fully sync with server, all lockpicking or unlock spells now sync for all players
- Improvements to holdstone parcel control, allowing fine grained access including access for people outside the hold (gonna be an awesome system when done)
- Optimizations on FPS issues after unloading entitys in the world, found a memory leak and plugged it
- Optimizations on FPS issues with static objects that need updated that are not within view
- Added some diagnostics to smelting to catch why items get reverted during breakdown (will need more diagnostics after smelting)
- Added hall of the dead to temples in Falkreath
- Completed Cure Poision, Cure Paralysis, Dispel, Calm, Demoralize, Rally, and Frenzy spell effects
