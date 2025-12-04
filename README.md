# 🎉 Universal Vote Reward System for Top-Serveurs.net

A comprehensive FiveM vote reward system that automatically detects and rewards players who vote for your server on top-serveurs.net.

![Version](https://img.shields.io/badge/version-3.0.0-blue.svg)
![Framework](https://img.shields.io/badge/framework-QBCore%20%7C%20ESX%20%7C%20QBX-green.svg)

## ✨ Features

- ✅ **Automatic vote detection** (checks every 30 seconds)
- ✅ **Connection-based verification** - Rewards on join
- ✅ **Manual claiming** with `/checkvote`
- ✅ **Multi-framework**: QBCore, ESX, QBX
- ✅ **Multi-notification**: QBCore, ox_lib, ESX, okokNotify, Mythic
- ✅ **MySQL tracking** with anti-duplicate protection
- ✅ **Discord webhooks** with clickable vote link
- ✅ **Multi-language** (FR/EN included)
- ✅ **Admin commands** to force rewards
- ✅ **Auto database setup** - No SQL needed!

## 📦 Quick Install

1. Download and extract to `resources/vote/`
2. Get your token from top-serveurs.net
3. Edit `config.lua`:
   - Set `Config.VoteToken`
   - Set `Config.Framework`
   - Set `Config.NotificationSystem`
4. Add `ensure vote` to server.cfg
5. Restart server

**That's it!** Database table creates automatically.

For detailed instructions, see [INSTALL.md](INSTALL.md)

## 🎮 Commands

**Players:**
- `/vote` - Show voting info
- `/checkvote` - Claim reward
- `/votehelp` - Show help

**Admins:**
- `/forcervote [id]` - Force reward

## ⚙️ Configuration

Everything is in `config.lua`:
- Reward amount & type
- Check interval (30s default)
- Discord webhook
- Notification system
- Language (FR/EN)
- And more!

## 📝 Documentation

- [Installation Guide](INSTALL.md) - Detailed setup
- [README Français](README_fr.md) - Version française
- [Changelog](CHANGELOG.md) - Version history

## 🔧 Support

- Enable `Config.Debug = true` for logs
- Check console for errors
- Open GitHub issue with details

## 👨‍💻 Credits

**Author:** RPQC / Seb  
**API:** Top-Serveurs.net  
**License:** MIT

---

**Made with ❤️ for the FiveM community**
