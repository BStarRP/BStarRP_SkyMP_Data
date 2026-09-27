# Patch notes

## Changes
- Fixed a crash from wearing a weapon with armor
- Fixed Magelight orbs getting stuck or not showing up
- Fixed a server crash caused by leftover potion and poison effects
- Fixed the server freezing while checking in with the master server
- Fixed food and drink taking effect before you finish eating or drinking
- Fixed Wolfskull enemies freezing when they appear
- Fixed Skooma withdrawal ending too early. It now lasts until the addiction ends, and old stuck withdrawals clear when you log in
- Fixed items and locations after a mod update. Your items are kept, removed-mod items are dropped, and you are sent to the Temple of Kynareth if your location is gone
- Fixed fire, frost, and shock on weapons. Armor does not block that damage. Resistance does. A perfect parry blocks it
- Fixed enchanting at the arcane enchanter doing nothing after selecting a soul gem
- Fixed characters getting stuck or turning invisible when they appear
- Fixed a login repair that could overwrite your saved items
- Fixed Argonian claw damage while wearing heavy armor
- Added Disarm. It stops you from immediately pulling your weapon back out
- Added icons in the trade window, on your stats and attributes, and as badges on fortify, restore, damage, and drain effects
- Added pet dismissal that makes pets, summons, and thralls walk away for 5 seconds before despawning, plus compass markers for pets, group mates, and hostiles
- Updated compass markers to four colored orbs with no labels: yellow for pets and thralls, blue for summons, green for allies and group mates, and red for hostiles and ranger marks
- Fixed stuck script waits piling up on the server. They now clear after 15 seconds, with at most 64 waiting at once
- Improved server performance by loading the plugin file list once at startup
- Improved server performance by reading save records without copying them
- Improved server performance by skipping equipment sync when stamina, health, or magicka changes
- Fixed the Windows server build
