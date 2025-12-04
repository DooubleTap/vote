# 🎉 Universal Vote Reward System for Top-Serveurs.net

A comprehensive FiveM vote reward system that automatically detects and rewards players who vote for your server on top-serveurs.net. Built with multi-framework support and extensive configuration options.

![Version](https://img.shields.io/badge/version-3.0.0-blue.svg)
![Framework](https://img.shields.io/badge/framework-QBCore%20%7C%20ESX%20%7C%20QBX-green.svg)
![License](https://img.shields.io/badge/license-MIT-orange.svg)

## 📋 Features

### Core Features
- ✅ **Automatic vote detection** via IP matching
- ✅ **Manual vote claiming** with `/checkvote` command
- ✅ **Connection-based verification** - Rewards on player connection if they voted
- ✅ **MySQL database tracking** - Permanent vote history with anti-duplicate protection
- ✅ **2-hour cooldown system** managed by Top-Serveurs API

### Multi-Framework Support
- 🎯 **QBCore** (qb-core)
- 🎯 **ESX** (es_extended)
- 🎯 **QBX Core** (qbx_core)

### Notification Systems Supported
- 📢 QBCore native notifications
- 📢 ox_lib notifications
- 📢 ESX notifications
- 📢 okokNotify
- 📢 Mythic Notify
- 📢 Custom notification system support

### Additional Features
- 🌍 **Multi-language** (English & French included, easily extensible)
- 🔔 **Discord webhook integration** for vote logging
- 🎵 **Sound effects** on reward receipt
- 💬 **Chat messages** for vote confirmations
- ⏰ **Automatic vote reminders** (configurable)
- 🛡️ **Anti-exploit protection** with cooldown and IP caching
- 🔧 **Fully configurable** - Everything in config.lua
- 📊 **Admin commands** to force vote rewards
- 🐛 **Debug mode** for troubleshooting

## 📦 Installation

### Prerequisites
- FiveM server with txAdmin
- MySQL database (oxmysql recommended)
- QBCore, ESX, or QBX framework
- Top-Serveurs.net account with server registered

### Step 1: Download & Extract

1. Download the latest release
2. Extract the `vote` folder to your server's `resources` directory
3. Ensure the folder structure looks like this:
   ```
   resources/
   └── vote/
       ├── fxmanifest.lua
       ├── config.lua
       ├── notifications.lua
       ├── client/
       │   └── main.lua
       └── server/
           └── main.lua
   ```

### Step 2: Get Your Top-Serveurs Token

1. Go to [https://top-serveurs.net](https://top-serveurs.net)
2. Log in to your account
3. Navigate to your server's dashboard
4. Go to **API** section
5. Copy your **Server Token**

### Step 3: Configure the Script

Open `config.lua` and configure:

```lua
-- Set your language
Config.Locale = 'en' -- Options: 'en', 'fr'

-- Set your framework
Config.Framework = 'qb-core' -- Options: 'qb-core', 'esx', 'qbx_core'

-- Set your notification system
Config.NotificationSystem = 'qbcore' -- Options: 'qbcore', 'ox_lib', 'esx', 'okok', 'mythic', 'custom'

-- Add your Top-Serveurs token
Config.VoteToken = "YOUR_TOKEN_HERE"

-- Configure rewards
Config.RewardAmount = 500
Config.RewardType = 'cash' -- Options: 'cash', 'bank'

-- Discord Webhook (optional)
Config.UseDiscordWebhook = true
Config.DiscordWebhook = "YOUR_WEBHOOK_URL_HERE"
```

### Step 4: Database Setup

The script automatically creates the required database table on first start. No manual SQL execution needed!

The table structure:
```sql
vote_rewards (
    id, citizenid, player_name, ip_address,
    reward_amount, reward_type, vote_source,
    claimed_at
)
```

### Step 5: Add to server.cfg

Add this line to your `server.cfg`:

```cfg
ensure vote
```

### Step 6: Restart Your Server

Restart your FiveM server or use:
```
refresh
ensure vote
```

## 🎮 Usage

### For Players

**Vote and get rewarded:**
1. Vote for the server on [top-serveurs.net](https://top-serveurs.net)
2. Either:
   - Wait for automatic detection (checks every 5 minutes)
   - Type `/checkvote` in-game to claim immediately
   - Reconnect to the server (checks on connection)

**Available Commands:**
- `/vote` - Display voting information
- `/checkvote` - Check and claim your vote reward
- `/votehelp` - Show all vote commands

### For Admins

**Admin Commands:**
- `/forcervote [player_id]` - Force a vote reward for a player (requires admin permission)

**Debug Commands:**
- `/votedebug` - Display player's vote statistics (when debug mode is enabled)

## ⚙️ Configuration Options

### Rewards
```lua
Config.RewardAmount = 500          -- Amount to give
Config.RewardType = 'cash'         -- 'cash' or 'bank'
```

### Performance
```lua
Config.CheckInterval = 300000      -- Auto-check every 5 minutes
Config.IPCacheTimeout = 900        -- IP cache duration (15 min)
```

### Features
```lua
Config.VoteReminder = true                -- Enable hourly reminders
Config.VoteReminderInterval = 3600000     -- Reminder interval (1 hour)
Config.PlaySoundOnReward = true           -- Play sound effect
Config.ShowChatMessage = true             -- Show chat message
```

### Database
```lua
Config.DatabaseCleanup = true      -- Auto-cleanup old votes
Config.DatabaseCleanupDays = 30    -- Keep history for 30 days
```

### Debug
```lua
Config.Debug = false               -- Enable detailed logging
```

## 🔧 Troubleshooting

### Votes Not Detected Automatically
1. Check your token is correct in `config.lua`
2. Enable debug mode: `Config.Debug = true`
3. Check server console for error messages
4. Verify your firewall allows outbound connections to `api.top-games.net`

### Duplicate Rewards
- The system has built-in anti-duplicate protection
- 2-hour cooldown between vote claims per player
- Database tracking prevents multiple claims

### Discord Webhook Not Working
1. Verify webhook URL is correct
2. Ensure `Config.UseDiscordWebhook = true`
3. Check server console for webhook error codes

## 📝 Adding Custom Languages

To add a new language, edit `config.lua`:

```lua
Config.Locales['es'] = {
    ['vote_received'] = '¡Gracias por votar! ¡Recibiste $%s!',
    ['vote_checking'] = 'Verificando tu voto...',
    -- ... add all translation keys
}
```

Then set: `Config.Locale = 'es'`

## 🤝 Support & Contributing

- **Issues**: Open an issue on GitHub
- **Pull Requests**: Contributions are welcome!
- **Discord**: Join our community server

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 👨‍💻 Credits

- **Author**: RPQC / Seb
- **Framework**: QBCore / ESX / QBX
- **API**: Top-Serveurs.net

## ⭐ Show Your Support

If you find this resource helpful, please consider:
- ⭐ Starring the repository
- 🐛 Reporting bugs
- 💡 Suggesting new features
- 📢 Sharing with others

---

**Made with ❤️ for the FiveM community**