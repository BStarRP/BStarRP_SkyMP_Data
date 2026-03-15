# Patch notes

**Summary**
Gamemode and crafting updates (leatherworking/loom), persistent admin teleport locations, server logging improvements (tee server, tick rate monitor, full-length lines), a looser combat validation distance, and Font Awesome skill icons in the skills menu.

## Additions
- Added leatherworking skill and loom support (crafting system)
- Added persistent admin teleport locations (saved tp locations for admins)
- Added Font Awesome support for skill icons in the skills menu
- Added tee server and tick rate monitor for server logging
- Added More Craftable Equipment and hooked into skills

## Fixes
- Server log lines now display at full length (no truncation)
- Improved console logging on the server
- Combat validation max distance loosened (less strict range check)

## Infrastructure
- Server logging pipeline (tee + tick rate monitor) for better diagnostics