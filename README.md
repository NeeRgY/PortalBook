<div align="center">
<img src="https://img.shields.io/github/v/release/NeeRgY/PortalBook?style=for-the-badge" />
<img src="https://img.shields.io/github/last-commit/NeeRgY/PortalBook?style=for-the-badge" />
<img src="https://img.shields.io/github/issues/NeeRgY/PortalBook?style=for-the-badge" />
<img src="https://img.shields.io/github/stars/NeeRgY/PortalBook?style=for-the-badge" />
<br><br>

[![Curseforge](https://img.shields.io/curseforge/dt/1439483?label=CurseForge&color=F16436&style=for-the-badge)](https://www.curseforge.com/wow/addons/portal-book)
[![Discord](https://img.shields.io/discord/1538823169446645762?style=for-the-badge&label=Discord&color=5865F2)](https://discord.gg/YjfyDKckCS)
<br>

[![ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/neergy)

</div>

---
__PortalBook__ is a lightweight addon for Mages that provides a clean, modern interface to access all Teleport and Portal spells in one convenient window.

Supports __Retail__ (Midnight), __Burning Crusade Classic__, and __Classic Era__.

## Features

- __Modern UI:__ Dark panel with teleports on the left, portals on the right, and destination names in the center – always faction-aware (Alliance/Horde)
- __Smart spell detection:__ Learned spells are ready to cast. Unlearned spells show as desaturated/red with level requirement and where to learn them. Newly learned spells appear instantly, without reopening the window
- __Clickable spell buttons:__ Cast teleports and portals directly from the interface
- __Minimap button:__ Left-click to open/close, right-click + drag to move it around the ring, can be hidden in the settings
- __Movable & resizable window:__ Drag to reposition, position, size and all settings are saved automatically. Press `Esc` to close
- __Class check:__ Non-mages see a red “Not a Mage” warning in the title bar
- __Cast counter:__ Counts every teleport and portal you cast – including casts straight from the spellbook, regardless of the active tab
- __Party/raid announce:__ Optional “Open a Portal to X” message when you open a portal (portals only, never plain teleports), always posted in English so the whole group reads the same message

&nbsp;

## Settings

Open with the gear icon in the title bar. All controls are custom-themed to match the interface (checkboxes, sliders, dropdown).

- __Show counter__ with a reset button (on by default)
- __Show only learned__ spells (off by default)
- __Auto-close__ the window on cast (off by default)
- __Announce portal__ in party/raid (off by default)
- __Transparency__ slider for the whole interface
- __Scale__ slider – resizes the main window and every popup (70–150 %)
- __Language__ selector – force any bundled language in-game, no `/reload` needed. “Automatic” follows the game client
- __Minimap icon__ toggle
- __Changelog__ and __About__ buttons at the bottom open their own popups (the changelog never pops up on its own)

&nbsp;



## Client differences

### Retail
- Expansion filter tabs (including “All”)
- Search bar and scrollable destination list
- Destinations from capitals through current expansions

### Classic / TBC
- Same look as Retail, without tabs, search, or scrollbar
- Flat destination list with compact window height
- Rune of Teleportation / Rune of Portals counts in the footer
- Learn tooltips with the correct portal trainer per city

&nbsp;

## Supported Spells

### Retail
Capitals and hubs across expansions (Alliance/Horde/neutral as appropriate), including Outland, Northrend, Cataclysm, Pandaria, Warlords, Legion, Battle for Azeroth, Shadowlands, Dragonflight, The War Within, and Midnight.

### Burning Crusade Classic
__Alliance:__ Stormwind, Ironforge, Darnassus, Exodar, Theramore, Shattrath  
__Horde:__ Orgrimmar, Undercity, Thunder Bluff, Silvermoon, Stonard, Shattrath

### Classic Era
__Alliance:__ Stormwind, Ironforge, Darnassus  
__Horde:__ Orgrimmar, Undercity, Thunder Bluff

&nbsp;

## Languages
- English (enUS)
- German (deDE)
- French (frFR)
- Spanish (esES)
- Spanish (esMX)
- Italian (itIT)
- Russian (ruRU)

&nbsp;

## Usage

- Type `/portalb` or `/pb`, or click the minimap button, to toggle the window
- Drag the window to reposition it, use the __Scale__ slider in Options to resize it (position and size are saved automatically)
- Press `Esc` to close the window
- Optional: create a macro with `/portalb` to open the UI from an action bar button
