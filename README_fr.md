# 🎉 Système Universel de Récompenses de Vote pour Top-Serveurs.net

Un système complet de récompenses de vote pour FiveM qui détecte et récompense automatiquement les joueurs qui votent pour votre serveur sur top-serveurs.net. Conçu avec support multi-framework et options de configuration étendues.

![Version](https://img.shields.io/badge/version-3.0.0-blue.svg)
![Framework](https://img.shields.io/badge/framework-QBCore%20%7C%20ESX%20%7C%20QBX-green.svg)
![License](https://img.shields.io/badge/license-MIT-orange.svg)

## 📋 Fonctionnalités 

### Fonctionnalités Principales
- ✅ **Détection automatique des votes** via correspondance d'IP
- ✅ **Réclamation manuelle** avec la commande `/checkvote`
- ✅ **Vérification à la connexion** - Récompense automatique si le joueur a voté
- ✅ **Base de données MySQL** - Historique permanent avec protection anti-doublon
- ✅ **Cooldown de 2 heures** géré par l'API Top-Serveurs

### Support Multi-Framework
- 🎯 **QBCore** (qb-core)
- 🎯 **ESX** (es_extended)
- 🎯 **QBX Core** (qbx_core)

### Systèmes de Notifications Supportés
- 📢 Notifications natives QBCore
- 📢 Notifications ox_lib
- 📢 Notifications ESX
- 📢 okokNotify
- 📢 Mythic Notify
- 📢 Support système de notification personnalisé

### Fonctionnalités Additionnelles
- 🌍 **Multi-langue** (Français & Anglais inclus, facilement extensible)
- 🔔 **Intégration Discord webhook** pour journalisation des votes
- 🎵 **Effets sonores** lors de la réception de récompense
- 💬 **Messages de chat** pour confirmation des votes
- ⏰ **Rappels automatiques de vote** (configurable)
- 🛡️ **Protection anti-exploit** avec cooldown et cache d'IP
- 🔧 **Entièrement configurable** - Tout dans config.lua
- 📊 **Commandes admin** pour forcer les récompenses de vote
- 🐛 **Mode debug** pour dépannage

## 📦 Installation

### Prérequis
- Serveur FiveM avec txAdmin
- Base de données MySQL (oxmysql recommandé)
- Framework QBCore, ESX, ou QBX
- Compte Top-Serveurs.net avec serveur enregistré

### Étape 1: Téléchargement & Extraction

1. Téléchargez la dernière version
2. Extrayez le dossier `vote` dans le répertoire `resources` de votre serveur
3. Assurez-vous que la structure ressemble à ceci:
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

### Étape 2: Obtenir Votre Token Top-Serveurs

1. Allez sur [https://top-serveurs.net](https://top-serveurs.net)
2. Connectez-vous à votre compte
3. Naviguez vers le tableau de bord de votre serveur
4. Allez dans la section **API**
5. Copiez votre **Token Serveur**

### Étape 3: Configuration du Script

Ouvrez `config.lua` et configurez:

```lua
-- Définir votre langue
Config.Locale = 'fr' -- Options: 'fr', 'en'

-- Définir votre framework
Config.Framework = 'qb-core' -- Options: 'qb-core', 'esx', 'qbx_core'

-- Définir votre système de notifications
Config.NotificationSystem = 'qbcore' -- Options: 'qbcore', 'ox_lib', 'esx', 'okok', 'mythic', 'custom'

-- Ajoutez votre token Top-Serveurs
Config.VoteToken = "VOTRE_TOKEN_ICI"

-- Configurer les récompenses
Config.RewardAmount = 500
Config.RewardType = 'cash' -- Options: 'cash', 'bank'

-- Discord Webhook (optionnel)
Config.UseDiscordWebhook = true
Config.DiscordWebhook = "VOTRE_URL_WEBHOOK_ICI"
```

### Étape 4: Configuration de la Base de Données

Le script crée automatiquement la table requise au premier démarrage. Aucune exécution SQL manuelle nécessaire!

Structure de la table:
```sql
vote_rewards (
    id, citizenid, player_name, ip_address,
    reward_amount, reward_type, vote_source,
    claimed_at
)
```

### Étape 5: Ajouter à server.cfg

Ajoutez cette ligne à votre `server.cfg`:

```cfg
ensure vote
```

### Étape 6: Redémarrer Votre Serveur

Redémarrez votre serveur FiveM ou utilisez:
```
refresh
ensure vote
```

## 🎮 Utilisation

### Pour les Joueurs

**Voter et recevoir des récompenses:**
1. Votez pour le serveur sur [top-serveurs.net](https://top-serveurs.net)
2. Soit:
   - Attendez la détection automatique (vérification toutes les 5 minutes)
   - Tapez `/checkvote` en jeu pour réclamer immédiatement
   - Reconnectez-vous au serveur (vérification à la connexion)

**Commandes Disponibles:**
- `/vote` - Afficher les informations de vote
- `/checkvote` - Vérifier et réclamer votre récompense de vote
- `/votehelp` - Afficher toutes les commandes de vote

### Pour les Admins

**Commandes Admin:**
- `/forcervote [player_id]` - Forcer une récompense de vote pour un joueur (nécessite permission admin)

**Commandes Debug:**
- `/votedebug` - Afficher les statistiques de vote du joueur (quand le mode debug est activé)

## ⚙️ Options de Configuration

### Récompenses
```lua
Config.RewardAmount = 500          -- Montant à donner
Config.RewardType = 'cash'         -- 'cash' ou 'bank'
```

### Performance
```lua
Config.CheckInterval = 300000      -- Vérification auto toutes les 5 minutes
Config.IPCacheTimeout = 900        -- Durée du cache IP (15 min)
```

### Fonctionnalités
```lua
Config.VoteReminder = true                -- Activer rappels horaires
Config.VoteReminderInterval = 3600000     -- Intervalle de rappel (1 heure)
Config.PlaySoundOnReward = true           -- Jouer un effet sonore
Config.ShowChatMessage = true             -- Afficher message dans le chat
```

### Base de Données
```lua
Config.DatabaseCleanup = true      -- Nettoyage auto des anciens votes
Config.DatabaseCleanupDays = 30    -- Garder l'historique 30 jours
```

### Debug
```lua
Config.Debug = false               -- Activer logs détaillés
```

## 🔧 Dépannage

### Votes Non Détectés Automatiquement
1. Vérifiez que votre token est correct dans `config.lua`
2. Activez le mode debug: `Config.Debug = true`
3. Vérifiez la console serveur pour messages d'erreur
4. Vérifiez que votre pare-feu autorise les connexions sortantes vers `api.top-games.net`

### Récompenses Dupliquées
- Le système a une protection anti-doublon intégrée
- Cooldown de 2 heures entre les réclamations par joueur
- Le suivi en base de données empêche les réclamations multiples

### Webhook Discord Ne Fonctionne Pas
1. Vérifiez que l'URL du webhook est correcte
2. Assurez-vous que `Config.UseDiscordWebhook = true`
3. Vérifiez la console serveur pour codes d'erreur webhook

## 📝 Ajouter des Langues Personnalisées

Pour ajouter une nouvelle langue, éditez `config.lua`:

```lua
Config.Locales['es'] = {
    ['vote_received'] = '¡Gracias por votar! ¡Recibiste $%s!',
    ['vote_checking'] = 'Verificando tu voto...',
    -- ... ajoutez toutes les clés de traduction
}
```

Puis définissez: `Config.Locale = 'fr'`

## 🤝 Support & Contribution

- **Problèmes**: Ouvrez une issue sur GitHub
- **Pull Requests**: Les contributions sont les bienvenues!
- **Discord**: Rejoignez notre serveur communautaire

## 📄 Licence

Ce projet est sous licence MIT - voir le fichier LICENSE pour plus de détails.

## 👨‍💻 Crédits

- **Auteur**: RPQC / Seb
- **Framework**: QBCore / ESX / QBX
- **API**: Top-Serveurs.net

## ⭐ Montrez Votre Support

Si vous trouvez cette ressource utile, veuillez considérer:
- ⭐ Mettre une étoile au dépôt
- 🐛 Signaler des bugs
- 💡 Suggérer de nouvelles fonctionnalités
- 📢 Partager avec d'autres

---

**Fait avec ❤️ pour la communauté FiveM**