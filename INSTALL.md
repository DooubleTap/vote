# Installation Guide

## Prerequisites
- FiveM server with txAdmin
- MySQL (oxmysql recommended)
- QBCore, ESX, or QBX framework
- Top-Serveurs.net account

## Steps

### 1. Download
Extract `vote` folder to `resources/`

### 2. Get API Token
1. Visit top-serveurs.net
2. Go to your server dashboard
3. Navigate to API section
4. Copy your Server Token

### 3. Configure
Edit `config.lua`:
```lua
Config.VoteToken = "YOUR_TOKEN_HERE"
Config.VoteURL = "https://top-serveurs.net/gta/vote/YOUR_SERVER"
Config.Framework = 'qb-core' -- or 'esx', 'qbx_core'
Config.NotificationSystem = 'qbcore' -- or 'ox_lib', 'esx', etc
```

### 4. Discord Webhook (Optional)
```lua
Config.UseDiscordWebhook = true
Config.DiscordWebhook = "YOUR_WEBHOOK_URL"
```

### 5. Add to server.cfg
```
ensure vote
```

### 6. Restart Server
Database table creates automatically!

## Verify Installation
Check console for:
```
[VOTE] Système de vote Top-Serveurs chargé
[VOTE] Base de données initialisée avec succès
```

## Test
1. Vote on top-serveurs.net
2. Join server
3. Type `/checkvote`
4. Receive reward!

## Troubleshooting

**Votes not detected?**
- Check token is correct
- Enable `Config.Debug = true`
- Verify firewall allows api.top-games.net

**Database errors?**
- Ensure oxmysql is running
- Check database credentials

**Discord webhook not working?**
- Verify URL format
- Ensure `Config.UseDiscordWebhook = true`

For more help, open a GitHub issue!
