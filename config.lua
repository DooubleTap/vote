Config = {}

-- CONFIGURATION GÉNÉRALE / GENERAL CONFIGURATION
Config.Locale = 'fr' -- Langue / Language: 'fr', 'en'

-- FRAMEWORK
Config.Framework = 'qb-core' -- Framework: 'qb-core', 'esx', 'qbx_core'

-- SYSTÈME DE NOTIFICATIONS / NOTIFICATION SYSTEM
Config.NotificationSystem = 'qbcore' -- Options: 'qbcore', 'ox_lib', 'esx', 'okok', 'mythic', 'custom'
-- Si vous utilisez un système custom, configurez la fonction dans notifications.lua
-- If using custom system, configure the function in notifications.lua

-- TOP-SERVEURS API
Config.VoteToken = "CHANGE_ME_NOW" -- Obtenir sur / Get from: https://top-serveurs.net/gta

-- RÉCOMPENSES / REWARDS
Config.RewardAmount = 500                -- Montant de la récompense / Reward amount
Config.RewardType = 'bank'               -- Type: 'cash' ou 'bank' / Type: 'cash' or 'bank'

-- Récompenses multiples (optionnel) / Multiple rewards (optional)
Config.MultipleRewards = false           -- Activer les récompenses multiples / Enable multiple rewards
Config.Rewards = {
    {type = 'money', account = 'cash', amount = 500},
    -- {type = 'item', name = 'water', amount = 1},
    -- {type = 'item', name = 'sandwich', amount = 1},
}

-- NOTIFICATIONS
Config.NotificationDuration = 8000       -- Durée en ms / Duration in ms

-- DISCORD WEBHOOK
Config.UseDiscordWebhook = true          -- Activer les webhooks Discord / Enable Discord webhooks
Config.DiscordWebhook = "CHANGE_ME_WITH_YOUR_WEBHOOK_LINK"

-- Couleurs Discord (format décimal) / Discord colors (decimal format)
Config.DiscordColors = {
    success = 65280,    -- Vert / Green
    error = 16711680,   -- Rouge / Red
    warning = 16776960, -- Orange / Orange
    admin = 3447003     -- Bleu / Blue
}

-- PERFORMANCES
Config.CheckInterval = 300000            -- Vérification toutes les 5 minutes / Check every 5 minutes (300000 = 5min)
Config.CacheCleanupInterval = 600000     -- Nettoyage cache / Cache cleanup (600000 = 10min)
Config.IPCacheTimeout = 900              -- Cache IP en secondes / IP cache in seconds (900 = 15min)

-- COMMANDES / COMMANDS
Config.Commands = {
    checkVote = 'checkvote',             -- Commande pour vérifier son vote / Command to check vote
    forceVote = 'forcervote',            -- Commande admin pour forcer / Admin command to force
    vote = 'vote',                       -- Commande pour afficher les infos / Command to show info
    voteHelp = 'votehelp',              -- Commande d'aide / Help command
}

-- PERMISSIONS ADMIN
Config.AdminPermission = 'admin'         -- Permission requise pour commandes admin / Required permission for admin commands

-- FONCTIONNALITÉS CLIENT / CLIENT FEATURES
Config.VoteReminder = false               -- Rappel automatique pour voter / Automatic vote reminder
Config.VoteReminderInterval = 3600000    -- Intervalle de rappel en ms / Reminder interval in ms (3600000 = 1 heure / 1 hour)
Config.PlaySoundOnReward = true          -- Jouer un son lors de la récompense / Play sound on reward
Config.ShowChatMessage = true            -- Afficher message dans le chat / Show chat message

-- DATABASE
Config.DatabaseCleanup = true            -- Nettoyer les anciens votes / Cleanup old votes
Config.DatabaseCleanupDays = 30          -- Garder l'historique X jours / Keep history for X days

-- DEBUG
Config.Debug = false                     -- Activer les logs détaillés / Enable detailed logs

-- TRADUCTIONS / TRANSLATIONS
Config.Locales = {
    ['fr'] = {
        -- Notifications joueur
        ['vote_received'] = 'Merci pour ton vote! Tu as reçu $%s!',
        ['vote_checking'] = 'Vérification de ton vote en cours...',
        ['vote_not_found'] = 'Aucun vote trouvé. Assure-toi d\'avoir voté sur top-serveurs.net!',
        ['vote_error'] = 'Erreur lors de la vérification du vote',
        ['vote_cooldown'] = 'Tu as déjà réclamé un vote! Attends encore %s minutes.',
        ['vote_forced'] = 'Un admin t\'a donné $%s (vote forcé)',
        ['reward_given'] = 'Récompense donnée à %s',
        ['player_not_found'] = 'Joueur introuvable',
        ['vote_info'] = 'Vote pour RPQC sur top-serveurs.net et reçois $%s!',
        ['vote_info_command'] = 'Utilise /%s après avoir voté pour réclamer ta récompense',
        ['vote_reminder'] = '💎 N\'oublie pas de voter pour le serveur sur top-serveurs.net!',
        ['vote_reminder_command'] = 'Utilise /%s pour plus d\'infos',
        ['cooldown_wait'] = 'Attends %s secondes avant de revérifier',
        
        -- Commandes
        ['command_checkvote'] = 'Vérifier et réclamer ta récompense de vote',
        ['command_forcervote'] = 'Forcer une récompense de vote (Admin)',
        ['command_forcervote_arg'] = 'ID du joueur',
        ['command_vote'] = 'Afficher les informations pour voter',
        ['command_votehelp'] = 'Afficher l\'aide des commandes de vote',
        
        -- Messages système
        ['system_loaded'] = 'Système de vote Top-Serveurs chargé',
        ['api_check_info'] = 'Vérification toutes les %s secondes',
        ['api_error'] = 'Erreur API Top-Serveurs: Code %s',
        ['db_success'] = 'Base de données initialisée avec succès',
        ['db_error'] = 'Erreur lors de l\'initialisation de la base de données',
        
        -- Discord
        ['discord_footer'] = 'RPQC - Système de votes',
        ['discord_vote_rewarded'] = '🎉 Vote récompensé!',
        ['discord_vote_connection'] = '🎉 Vote récompensé à la connexion',
        ['discord_vote_manual'] = '🎉 Vote récompensé (manuel)',
        ['discord_vote_forced'] = '⚠️ Vote forcé par admin',
        ['discord_player'] = '**Joueur:**',
        ['discord_id'] = '**ID:**',
        ['discord_citizenid'] = '**CitizenID:**',
        ['discord_reward'] = '**Récompense:**',
        ['discord_type'] = '**Type:**',
        ['discord_admin'] = '**Admin:**',
        
        -- Logs console
        ['reward_given_log'] = 'Récompense donnée à %s',
        ['reward_connection_log'] = 'Récompense de vote donnée à %s à la connexion',
        ['reward_manual_log'] = 'Récompense de vote donnée à %s (manuel)',
        
        -- Aide
        ['help_title'] = '[Vote - Aide] Commandes disponibles:',
        ['help_vote'] = 'Affiche les informations pour voter',
        ['help_checkvote'] = 'Vérifie et réclame ta récompense de vote',
        ['help_votelink'] = 'Obtenir le lien de vote',
    },
    
    ['en'] = {
        -- Player notifications
        ['vote_received'] = 'Thanks for voting! You received $%s!',
        ['vote_checking'] = 'Checking your vote...',
        ['vote_not_found'] = 'No vote found. Make sure you voted on top-serveurs.net!',
        ['vote_error'] = 'Error while checking vote',
        ['vote_cooldown'] = 'You already claimed a vote! Wait %s more minutes.',
        ['vote_forced'] = 'An admin gave you $%s (forced vote)',
        ['reward_given'] = 'Reward given to %s',
        ['player_not_found'] = 'Player not found',
        ['vote_info'] = 'Vote for RPQC on top-serveurs.net and receive $%s!',
        ['vote_info_command'] = 'Use /%s after voting to claim your reward',
        ['vote_reminder'] = '💎 Don\'t forget to vote for the server on top-serveurs.net!',
        ['vote_reminder_command'] = 'Use /%s for more info',
        ['cooldown_wait'] = 'Wait %s seconds before checking again',
        
        -- Commands
        ['command_checkvote'] = 'Check and claim your vote reward',
        ['command_forcervote'] = 'Force a vote reward (Admin)',
        ['command_forcervote_arg'] = 'Player ID',
        ['command_vote'] = 'Show voting information',
        ['command_votehelp'] = 'Show vote commands help',
        
        -- System messages
        ['system_loaded'] = 'Top-Serveurs vote system loaded',
        ['api_check_info'] = 'Checking every %s seconds',
        ['api_error'] = 'Top-Serveurs API Error: Code %s',
        ['db_success'] = 'Database initialized successfully',
        ['db_error'] = 'Error initializing database',
        
        -- Discord
        ['discord_footer'] = 'RPQC - Vote System',
        ['discord_vote_rewarded'] = '🎉 Vote Rewarded!',
        ['discord_vote_connection'] = '🎉 Vote rewarded on connection',
        ['discord_vote_manual'] = '🎉 Vote rewarded (manual)',
        ['discord_vote_forced'] = '⚠️ Vote forced by admin',
        ['discord_player'] = '**Player:**',
        ['discord_id'] = '**ID:**',
        ['discord_citizenid'] = '**CitizenID:**',
        ['discord_reward'] = '**Reward:**',
        ['discord_type'] = '**Type:**',
        ['discord_admin'] = '**Admin:**',
        
        -- Console logs
        ['reward_given_log'] = 'Reward given to %s',
        ['reward_connection_log'] = 'Vote reward given to %s on connection',
        ['reward_manual_log'] = 'Vote reward given to %s (manual)',
        
        -- Help
        ['help_title'] = '[Vote - Help] Available commands:',
        ['help_vote'] = 'Show voting information',
        ['help_checkvote'] = 'Check and claim your vote reward',
        ['help_votelink'] = 'Get the voting link',
    }
}

-- Fonction helper pour obtenir les traductions
function L(key, ...)
    local locale = Config.Locales[Config.Locale] or Config.Locales['en']
    local text = locale[key] or key
    
    if ... then
        return string.format(text, ...)
    end
    
    return text
end
