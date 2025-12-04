# 🎉 Système Universel de Récompenses de Vote pour Top-Serveurs.net

Un système complet de récompenses de vote pour FiveM qui détecte et récompense automatiquement les joueurs qui votent pour votre serveur.

![Version](https://img.shields.io/badge/version-3.0.0-blue.svg)
![Framework](https://img.shields.io/badge/framework-QBCore%20%7C%20ESX%20%7C%20QBX-green.svg)

## ✨ Fonctionnalités

- ✅ **Détection automatique** (vérification toutes les 30 secondes)
- ✅ **Vérification à la connexion** - Récompense automatique
- ✅ **Réclamation manuelle** avec `/checkvote`
- ✅ **Multi-framework**: QBCore, ESX, QBX
- ✅ **Multi-notifications**: QBCore, ox_lib, ESX, okokNotify, Mythic
- ✅ **Base MySQL** avec protection anti-doublon
- ✅ **Webhooks Discord** avec lien de vote cliquable
- ✅ **Multi-langue** (FR/EN inclus)
- ✅ **Commandes admin** pour forcer récompenses
- ✅ **Installation auto BD** - Aucun SQL nécessaire!

## 📦 Installation Rapide

1. Télécharger et extraire dans `resources/vote/`
2. Obtenir votre token sur top-serveurs.net
3. Éditer `config.lua`:
   - Définir `Config.VoteToken`
   - Définir `Config.Framework`
   - Définir `Config.NotificationSystem`
4. Ajouter `ensure vote` à server.cfg
5. Redémarrer le serveur

**C'est tout!** La table BD se crée automatiquement.

Pour des instructions détaillées, voir [INSTALL.md](INSTALL.md)

## 🎮 Commandes

**Joueurs:**
- `/vote` - Afficher infos de vote
- `/checkvote` - Réclamer récompense
- `/votehelp` - Afficher l'aide

**Admins:**
- `/forcervote [id]` - Forcer récompense

## ⚙️ Configuration

Tout est dans `config.lua`:
- Montant & type de récompense
- Intervalle de vérification (30s par défaut)
- Webhook Discord
- Système de notifications
- Langue (FR/EN)
- Et plus!

## 📝 Documentation

- [Guide d'installation](INSTALL.md) - Configuration détaillée
- [README English](README.md) - English version
- [Changelog](CHANGELOG.md) - Historique des versions

## 🔧 Support

- Activer `Config.Debug = true` pour les logs
- Vérifier la console pour les erreurs
- Ouvrir une issue GitHub avec détails

## 👨‍💻 Crédits

**Auteur:** RPQC / Seb  
**API:** Top-Serveurs.net  
**Licence:** MIT

---

**Fait avec ❤️ pour la communauté FiveM**
