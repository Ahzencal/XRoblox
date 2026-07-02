# LyraHub

Automation toolkit for IndoVoice on Roblox. Built with a custom violet-themed GUI, modular architecture, and persistent settings.

## Features

### Auto Fish
- Animation-based fishing engine (d8nte-style)
- Uses VirtualInputManager for casting, animation detection for bite/pull
- Auto re-equip rod on timeout
- Configurable timing (cast hold, pull timeout, post-pull delay)
- Performance monitor: fish/hr, rarity breakdown, earnings tracker

### Auto Gacha (BlindBox)
- 10x roll automation
- Auto-reads available boxes from ReplicatedStorage
- Stop-on-rarity: select target rarities and it stops when obtained
- Shows pet name and rarity from each roll

### FishZone
- FishZone ESP (highlights active zones)
- Auto TP to active fishing zones with body lock
- Auto Sell fish by selected rarities
- Sell Now (instant TP to shop and back)
- Refresh character (Adonis command)

### Player Tools
- Player ESP (box + nametag)
- Teleport to player
- Beam tracer
- Avatar inspect

### Auto Clicker
- Silent click via VirtualInputManager
- Adjustable CPS (1-100) with slider
- Pick target position with hotkey

### Rewards
- Auto Claim Daily Reward (loops every 1 hour)
- Auto Claim Session Reward slots 1-12 (loops every 1 hour)

### Settings
- Anti-Idle (disconnects Roblox idle detection)
- Webhook integration (Discord)
  - Fish caught notifications (filtered by rarity)
  - Sell notifications with earnings
  - Gacha jackpot alerts
  - Test webhook button
- Auto-sell rarity selection (toggle per rarity)
- Webhook rarity filter (toggle per rarity)
- Accent color presets
- Save/Load settings locally (auto-loads on start)

### UI
- Lyra violet/purple theme
- Wide layout (620x420)
- Draggable from top bar and bottom line
- Minimize to circular "L" orb
- Toggle with K key (minimize/restore)
- Loading and unloading animations match main GUI size
- Scrollable tabs for Settings and Fun
- Real-time Logs tab with timestamps

## File Structure

```
IndoVoice/
├── main.lua       # Entry point / loader
├── config.lua     # Configuration (keys, theme, sell rarities, webhook)
├── gui.lua        # Full GUI layout and elements
├── core.lua       # All logic (fishing, gacha, ESP, clicker, rewards, webhook)
└── README.md      # This file
```

## Usage

Execute `main.lua` with your script executor. The GUI loads after a brief animation. All settings persist locally via `LyraHub_Settings.json`.

## Hotkeys

| Key | Action |
|-----|--------|
| K | Minimize / Restore UI |
| F | Toggle Auto Clicker |
| P | Pick clicker target position |

## Credits

Created by **Ahzencal**

Discord: Ahzencal
Saweria: https://saweria.co/ahzencal

LyraHub est. 2026
