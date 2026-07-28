# Patch notes

**Summary**
Another big set of fixes/improvements, biggest thing though to note here is the new spell learning system that encourages roleplay with teachers!  Teachers as long as they have the spell can reduce the time to learn by 3 days!

Last major thing to note is the new holdstone system, this is a WIP framework, out the gate it will require admins to setup each parcel that belongs to the hold, so may take a little time to get off the ground properly!
 
## Changes
- Fixed an issue with several animals not giving XP for hunting
- Fixed an issue where keeps/forts/dens where still being counted as dungeons (this is why chests got wiped)
- Fixed an issue with last animations not sticking on players (i.e. go into tavern you dont see them sitting)
- Fixed an issue with drawing a bow and aiming not registering to remote players on the vertical graph
- Fixed an issue with casting spells causing animations to bleed back on the 3rd person graph causing weird behavior, first person removed animation graph for 3rd person and allowed to function fine
- Fixed an issue with having to relog to get health regeneration when sitting
- Fixed racial skill bonuses now reflect tier properly
- Fixed an issue with categorizing chitten mask with armor or buckler with tailoring
- Fixed standing stone powers being available after a relog, also switching stones to other abilities still have to wait cooldown
- Fixed an issue with alchemy not awarding a real potion
- Fixed alchemy so it now persistently tracks ingredients and recipes you leanred
- Fixed casting illusion spells, now properly applies buffs/stats + added movement bonus stat for hud
- Fixed enchanted armor not going through armor damage calulations + added effects to effects bar
- Fixed horses dropping ownership mid ride causing weird issues
- Fixed summoned entitys from also dropping ownership (will work for a pet system down the road)
- Fixed certain inn's not flagging for energy regen buff
- Fixed lockpicking doors/chests now unloock for everyone, dungeon regen resets all locks + dungeon keys unlock for everyone
- Fixed npc's from rapid firing spells, they now charge up, no more droidieka's
- Fixed scene placement again, we flipped wrong axis last time
- Fixed harvesting causing two notifications, changed animation to Study instead of pickup (causes another activate)
- Fixed an issue with translucent applying to people not sneaking
- Temporarily disabled the The Tower buff until we change how it works
- Made guard armours craftable
- Updated interior firepits to work with comfort buff
- Added "Death Toll" debuff after death, also you keep most buffs/debuffs from death
- Improved damage resists buff chips that show up on buff bar, damage resists now show up as stats above buffs
- Tempering armor now adds to armor value persistently
- Reduced base energy regen in half, to create more time for rest and use for Bards (<3 Big fan of bards here, will give more as we go)
- Rebalanced alchemy, strength is based on current skill tier, minor to deadly
- Improved blinking + disabled during racemenu
- Bardic Inspiration now gives health regeneration (This buff is a total multiplier)
- Laying in beds is now a thing, also gives regen rates
- Swapping standing stones is now on a 24hour cooldown, also blocked if you used an ability on cooldown
- Optimized how loot is generated when traveling around, we no longer run heavy calls on every container, just when its opened (this is apart of the fps loss in overworld)
- Updated XP for spell hits to gain extra experience if casting on a target (like weapons this is capped per targets with diminishing returns to prevent exploit farming)
- Updated staves to now give xp so colleges can use these for training if needed
- New spell training system, it takes 1 week per tier, masters of a school can teach others spells or speed up the process by 3x Days per 24 hour period, also start with 50 spell points, more will be given to college/court mage
- New holdstone system, people can pledge to be apart of a hold, jarls/stewards can control ranks and permissions within hold, including lock access. (this is a framework, will take a little bit to setup and get fully working)