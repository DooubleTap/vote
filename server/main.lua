local QBCore = nil
local ESX = nil

-- Initialiser le framework
if Config.Framework == 'qb-core' or Config.Framework == 'qbx_core' then
    QBCore = exports['qb-core']:GetCoreObject()
elseif Config.Framework == 'esx' then
    ESX = exports['es_extended']:getSharedObject()
end

-- Cache des IPs en mémoire
local ipVerifiees = {}

-- ═══════════════════════════════════════════════════════════
-- FONCTIONS UTILITAIRES / UTILITY FUNCTIONS (DÉCLARÉES EN PREMIER!)
-- ═══════════════════════════════════════════════════════════

local function DebugPrint(message)
    if Config.Debug then
        print("^3[VOTE DEBUG]^0 " .. message)
    end
end

local function LogPrint(message)
    print("^2[VOTE]^0 " .. message)
end

local function ErrorPrint(message)
    print("^1[VOTE ERROR]^0 " .. message)
end

function GetTableSize(t)
    local count = 0
    for _ in pairs(t) do count = count + 1 end
    return count
end

-- ═══════════════════════════════════════════════════════════
-- INITIALISATION BASE DE DONNÉES / DATABASE INITIALIZATION
-- ═══════════════════════════════════════════════════════════

local function InitialiserDatabase()
    MySQL.Async.execute([[
        CREATE TABLE IF NOT EXISTS vote_rewards (
            id INT AUTO_INCREMENT PRIMARY KEY,
            citizenid VARCHAR(50) NOT NULL,
            player_name VARCHAR(100) NOT NULL,
            ip_address VARCHAR(45) NOT NULL,
            reward_amount INT NOT NULL,
            reward_type VARCHAR(20) NOT NULL,
            vote_source VARCHAR(20) NOT NULL,
            claimed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            INDEX idx_citizenid (citizenid),
            INDEX idx_ip (ip_address),
            INDEX idx_claimed_at (claimed_at)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
    ]], {}, function(result)
        if result then
            LogPrint(L('db_success'))
        else
            ErrorPrint(L('db_error'))
        end
    end)
end

local function NettoyerCaches()
    local tempsActuel = os.time()
    
    -- Nettoyer les IPs vérifiées (cache mémoire)
    local avant = GetTableSize(ipVerifiees)
    for ip, temps in pairs(ipVerifiees) do
        if tempsActuel - temps > Config.IPCacheTimeout then
            ipVerifiees[ip] = nil
        end
    end
    local apres = GetTableSize(ipVerifiees)
    
    DebugPrint("Cache mémoire nettoyé - IPs: " .. avant .. " -> " .. apres)
    
    -- Nettoyer les anciens votes dans la DB (optionnel)
    if Config.DatabaseCleanup then
        MySQL.Async.execute('DELETE FROM vote_rewards WHERE claimed_at < DATE_SUB(NOW(), INTERVAL ? DAY)', {
            Config.DatabaseCleanupDays
        }, function(affectedRows)
            if affectedRows > 0 then
                DebugPrint("Nettoyage DB: " .. affectedRows .. " anciens votes supprimés (>" .. Config.DatabaseCleanupDays .. " jours)")
            end
        end)
    end
end

-- ═══════════════════════════════════════════════════════════
-- VÉRIFICATION ANTI-DOUBLE RÉCOMPENSE / ANTI-DUPLICATE CHECK
-- ═══════════════════════════════════════════════════════════

local function VerifierVoteRecent(citizenid, callback)
    MySQL.Async.fetchScalar('SELECT TIMESTAMPDIFF(SECOND, claimed_at, NOW()) as seconds_since FROM vote_rewards WHERE citizenid = @citizenid ORDER BY claimed_at DESC LIMIT 1', {
        ['@citizenid'] = citizenid
    }, function(secondsEcoules)
        if secondsEcoules then
            local tempsRestant = 7200 - secondsEcoules -- 2 heures
            if tempsRestant > 0 then
                callback(false, math.ceil(tempsRestant / 60))
            else
                callback(true, 0)
            end
        else
            callback(true, 0)
        end
    end)
end

-- ═══════════════════════════════════════════════════════════
-- DISCORD WEBHOOK
-- ═══════════════════════════════════════════════════════════

function EnvoyerDiscord(titre, msg, couleur)
    if not Config.UseDiscordWebhook then 
        DebugPrint("Discord webhook désactivé")
        return 
    end
    
    DebugPrint("Envoi webhook Discord: " .. titre)
    
    couleur = couleur or Config.DiscordColors.success
    
    local embed = {
        {
            ["color"] = couleur,
            ["title"] = titre,
            ["description"] = msg,
            ["footer"] = {
                ["text"] = "🗳️ Votez pour RPQC",
                ["icon_url"] = "https://i.imgur.com/AfFp7pu.png"
            },
            ["url"] = Config.VoteURL,
            ["timestamp"] = os.date("!%Y-%m-%dT%H:%M:%SZ")
        }
    }

    PerformHttpRequest(Config.DiscordWebhook, function(err, text, headers) 
        if err ~= 200 and err ~= 204 then
            ErrorPrint("Webhook Discord erreur code " .. tostring(err))
        else
            DebugPrint("Webhook Discord envoyé avec succès")
        end
    end, 'POST',
        json.encode({username = "Vote System", embeds = embed}),
        {['Content-Type'] = 'application/json'})
end

-- ═══════════════════════════════════════════════════════════
-- FONCTIONS DE RÉCOMPENSE / REWARD FUNCTIONS
-- ═══════════════════════════════════════════════════════════

local function DonnerRecompense(playerId, citizenid, playerName, playerIP, source)
    DebugPrint("DonnerRecompense appelé pour " .. playerName .. " (ID: " .. playerId .. ")")
    
    local player = nil
    if Config.Framework == 'qb-core' or Config.Framework == 'qbx_core' then
        player = QBCore.Functions.GetPlayer(tonumber(playerId))
    elseif Config.Framework == 'esx' then
        player = ESX.GetPlayerFromId(tonumber(playerId))
    end
    
    if not player then 
        ErrorPrint("Impossible de trouver le joueur " .. playerId)
        return 
    end
    
    -- VÉRIFIER DANS LA BASE DE DONNÉES SI VOTE RÉCENT
    VerifierVoteRecent(citizenid, function(peutVoter, minutesRestantes)
        if not peutVoter then
            ErrorPrint("Vote déjà réclamé par " .. playerName .. " - Attendre " .. minutesRestantes .. " minutes")
            
            -- SEULEMENT NOTIFIER SI C'EST UNE ACTION MANUELLE (/checkvote)
            if source == 'manual' then
                Notifications.Notify(tonumber(playerId), L('vote_cooldown', minutesRestantes), 'error', 5000)
            end
            return
        end
        
        DebugPrint("Vérification OK - Ajout de $" .. Config.RewardAmount .. " (" .. Config.RewardType .. ")")
        
        -- Donner la récompense selon le framework
        if Config.Framework == 'qb-core' or Config.Framework == 'qbx_core' then
            player.Functions.AddMoney(Config.RewardType, Config.RewardAmount, 'Vote Reward')
        elseif Config.Framework == 'esx' then
            if Config.RewardType == 'cash' then
                player.addMoney(Config.RewardAmount)
            else
                player.addAccountMoney('bank', Config.RewardAmount)
            end
        end
        
        -- ENREGISTRER DANS LA BASE DE DONNÉES
        MySQL.Async.insert('INSERT INTO vote_rewards (citizenid, player_name, ip_address, reward_amount, reward_type, vote_source) VALUES (@citizenid, @player_name, @ip_address, @reward_amount, @reward_type, @vote_source)', {
            ['@citizenid'] = citizenid,
            ['@player_name'] = playerName,
            ['@ip_address'] = playerIP,
            ['@reward_amount'] = Config.RewardAmount,
            ['@reward_type'] = Config.RewardType,
            ['@vote_source'] = source
        }, function(insertId)
            if insertId then
                DebugPrint("Vote enregistré en DB avec ID: " .. insertId)
            else
                ErrorPrint("Erreur lors de l'enregistrement du vote en DB")
            end
        end)
        
        LogPrint(L('reward_given_log', playerName))
        
        -- Notification joueur
        Notifications.Notify(tonumber(playerId), L('vote_received', Config.RewardAmount), 'success', Config.NotificationDuration)
        
        -- Trigger event client pour animation
        TriggerClientEvent('vote:client:rewardReceived', tonumber(playerId), Config.RewardAmount)
        
        -- WEBHOOK DISCORD (SANS IP)
        local sourceText = ""
        if source == 'connection' then
            sourceText = "À la connexion"
        elseif source == 'manual' then
            sourceText = "Commande /checkvote"
        elseif source == 'auto' then
            sourceText = "Détection automatique"
        else
            sourceText = "Administrateur"
        end
        
        local discordMessage = "**Joueur:** " .. playerName .. "\n" ..
                              "**ID:** " .. playerId .. "\n" ..
                              "**CitizenID:** " .. citizenid .. "\n" ..
                              "**Récompense:** $" .. Config.RewardAmount .. " (" .. Config.RewardType .. ")\n" ..
                              "**Source:** " .. sourceText
        
        EnvoyerDiscord("🎉 Vote récompensé!", discordMessage, Config.DiscordColors.success)
        
        LogPrint("Vote récompensé: " .. playerName .. " via " .. source)
    end)
end

-- ═══════════════════════════════════════════════════════════
-- VÉRIFICATION DES VOTES / VOTE CHECKING
-- ═══════════════════════════════════════════════════════════

local function RecupererVotesRecents()
    DebugPrint("Début vérification automatique des votes")
    
    local apiUrl = "https://api.top-games.net/v1/votes/last?server_token=" .. Config.VoteToken
    DebugPrint("URL API: " .. apiUrl)
    
    PerformHttpRequest(
        apiUrl,
        function(statusCode, response, headers)
            DebugPrint("Réponse API - Code HTTP: " .. tostring(statusCode))
            
            if statusCode == 200 then
                if not response or response == "" then
                    ErrorPrint("Réponse vide malgré code 200")
                    return
                end
                
                local success, data = pcall(json.decode, response)
                if not success then
                    ErrorPrint("Erreur décodage JSON: " .. tostring(data))
                    return
                end
                
                if data and data.success and data.votes then
                    LogPrint("Votes récupérés: " .. #data.votes)
                    DebugPrint("Données: " .. json.encode(data))
                    
                    -- TRAITER CHAQUE VOTE INDIVIDUELLEMENT
                    for i, vote in ipairs(data.votes) do
                        local voteIP = vote.ip
                        DebugPrint("Vote #" .. i .. " - IP: " .. voteIP .. " - Pseudo: " .. (vote.pseudo or "N/A"))
                        
                        -- Vérifier si cette IP a déjà été traitée RÉCEMMENT (cache court de 5 min)
                        if not ipVerifiees[voteIP] then
                            DebugPrint("IP " .. voteIP .. " non vérifiée, scan des joueurs...")
                            
                            local joueurTrouve = false
                            for _, playerId in ipairs(GetPlayers()) do
                                local player = nil
                                if Config.Framework == 'qb-core' or Config.Framework == 'qbx_core' then
                                    player = QBCore.Functions.GetPlayer(tonumber(playerId))
                                elseif Config.Framework == 'esx' then
                                    player = ESX.GetPlayerFromId(tonumber(playerId))
                                end
                                
                                if player then
                                    local playerEndpoint = GetPlayerEndpoint(playerId)
                                    local playerIP = playerEndpoint:match("([^:]+)")
                                    local playerName = GetPlayerName(playerId)
                                    
                                    DebugPrint("Comparaison: " .. playerName .. " IP=" .. playerIP .. " vs Vote IP=" .. voteIP)
                                    
                                    if playerIP == voteIP then
                                        LogPrint("MATCH TROUVÉ! " .. playerName .. " correspond à IP " .. voteIP)
                                        
                                        local citizenid = nil
                                        if Config.Framework == 'qb-core' or Config.Framework == 'qbx_core' then
                                            citizenid = player.PlayerData.citizenid
                                        elseif Config.Framework == 'esx' then
                                            citizenid = player.identifier
                                        end
                                        
                                        -- MARQUER L'IP COMME VÉRIFIÉE AVANT DE DONNER LA RÉCOMPENSE
                                        ipVerifiees[voteIP] = os.time()
                                        
                                        DonnerRecompense(playerId, citizenid, playerName, playerIP, 'auto')
                                        joueurTrouve = true
                                        break
                                    end
                                end
                            end
                            
                            if not joueurTrouve then
                                DebugPrint("Aucun joueur connecté avec IP " .. voteIP)
                                -- Marquer quand même pour éviter de re-scanner cette IP
                                ipVerifiees[voteIP] = os.time()
                            end
                        else
                            DebugPrint("IP " .. voteIP .. " déjà en cache mémoire (vérifiée il y a " .. (os.time() - ipVerifiees[voteIP]) .. "s)")
                        end
                    end
                else
                    DebugPrint("Données API invalides ou aucun vote")
                end
            elseif statusCode == 404 then
                DebugPrint("Aucun vote récent trouvé (404)")
            else
                ErrorPrint("Erreur HTTP " .. statusCode)
            end
            
            DebugPrint("Fin vérification automatique")
        end,
        'GET',
        '',
        {['Content-Type'] = 'application/json'}
    )
end

-- ═══════════════════════════════════════════════════════════
-- THREADS
-- ═══════════════════════════════════════════════════════════

-- Nettoyage périodique des caches
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(Config.CacheCleanupInterval)
        NettoyerCaches()
    end
end)

-- Vérification automatique des votes
Citizen.CreateThread(function()
    LogPrint("Thread de vérification automatique démarré")
    Citizen.Wait(10000)
    LogPrint(L('api_check_info', Config.CheckInterval / 1000))
    
    while true do
        Citizen.Wait(Config.CheckInterval)
        RecupererVotesRecents()
    end
end)

-- ═══════════════════════════════════════════════════════════
-- ÉVÉNEMENTS / EVENTS
-- ═══════════════════════════════════════════════════════════

if Config.Framework == 'qb-core' or Config.Framework == 'qbx_core' then
    AddEventHandler('QBCore:Server:PlayerLoaded', function(Player)
        DebugPrint("Joueur connecté - Vérification vote...")
        Citizen.Wait(5000)
        
        local playerId = Player.PlayerData.source
        local playerName = GetPlayerName(playerId)
        local playerEndpoint = GetPlayerEndpoint(playerId)
        local playerIP = playerEndpoint:match("([^:]+)")
        local citizenid = Player.PlayerData.citizenid
        
        LogPrint("Connexion: " .. playerName .. " (ID: " .. playerId .. ")")
        DebugPrint("IP extraite: " .. playerIP)
        
        -- NE PAS vérifier le cache pour la connexion - toujours vérifier
        DebugPrint("Vérification vote à la connexion pour " .. playerName)
        
        local apiUrl = "https://api.top-games.net/v1/votes/check-ip?server_token=" .. Config.VoteToken .. "&ip=" .. playerIP
        
        PerformHttpRequest(
            apiUrl,
            function(statusCode, response, headers)
                DebugPrint("Connexion - API Response Code: " .. tostring(statusCode))
                
                if statusCode == 200 then
                    local success, data = pcall(json.decode, response)
                    if success and data and data.success and data.code == 200 then
                        LogPrint("Vote trouvé pour " .. playerName .. " à la connexion!")
                        ipVerifiees[playerIP] = os.time()
                        
                        local player = QBCore.Functions.GetPlayer(tonumber(playerId))
                        if player then
                            DonnerRecompense(playerId, citizenid, playerName, playerIP, 'connection')
                        end
                    else
                        DebugPrint("Aucun vote en attente pour " .. playerName)
                    end
                end
            end,
            'GET',
            '',
            {['Content-Type'] = 'application/json'}
        )
    end)
elseif Config.Framework == 'esx' then
    AddEventHandler('esx:playerLoaded', function(playerId, xPlayer)
        DebugPrint("Joueur connecté - Vérification vote...")
        Citizen.Wait(5000)
        
        local playerName = GetPlayerName(playerId)
        local playerEndpoint = GetPlayerEndpoint(playerId)
        local playerIP = playerEndpoint:match("([^:]+)")
        local citizenid = xPlayer.identifier
        
        LogPrint("Connexion: " .. playerName .. " (ID: " .. playerId .. ")")
        DebugPrint("IP extraite: " .. playerIP)
        
        DebugPrint("Vérification vote à la connexion pour " .. playerName)
        
        local apiUrl = "https://api.top-games.net/v1/votes/check-ip?server_token=" .. Config.VoteToken .. "&ip=" .. playerIP
        
        PerformHttpRequest(
            apiUrl,
            function(statusCode, response, headers)
                DebugPrint("Connexion - API Response Code: " .. tostring(statusCode))
                
                if statusCode == 200 then
                    local success, data = pcall(json.decode, response)
                    if success and data and data.success and data.code == 200 then
                        LogPrint("Vote trouvé pour " .. playerName .. " à la connexion!")
                        ipVerifiees[playerIP] = os.time()
                        
                        local player = ESX.GetPlayerFromId(tonumber(playerId))
                        if player then
                            DonnerRecompense(playerId, citizenid, playerName, playerIP, 'connection')
                        end
                    else
                        DebugPrint("Aucun vote en attente pour " .. playerName)
                    end
                end
            end,
            'GET',
            '',
            {['Content-Type'] = 'application/json'}
        )
    end)
end

-- Event pour /checkvote depuis le client
RegisterNetEvent('vote:server:checkVote', function()
    local source = source
    local player = nil
    local citizenid = nil
    
    if Config.Framework == 'qb-core' or Config.Framework == 'qbx_core' then
        player = QBCore.Functions.GetPlayer(source)
        if player then
            citizenid = player.PlayerData.citizenid
        end
    elseif Config.Framework == 'esx' then
        player = ESX.GetPlayerFromId(source)
        if player then
            citizenid = player.identifier
        end
    end
    
    if not player then 
        ErrorPrint("Player introuvable pour source " .. source)
        return 
    end
    
    local playerName = GetPlayerName(source)
    local playerEndpoint = GetPlayerEndpoint(source)
    local playerIP = playerEndpoint:match("([^:]+)")
    
    LogPrint("/checkvote par " .. playerName)
    DebugPrint("IP: " .. playerIP)
    
    -- Vérifier en DB d'abord
    VerifierVoteRecent(citizenid, function(peutVoter, minutesRestantes)
        if not peutVoter then
            ErrorPrint(playerName .. " a déjà un vote réclamé - " .. minutesRestantes .. " minutes restantes")
            Notifications.Notify(source, L('vote_cooldown', minutesRestantes), 'error', 5000)
            return
        end
        
        Notifications.Notify(source, L('vote_checking'), 'info', 3000)
        
        local apiUrl = "https://api.top-games.net/v1/votes/check-ip?server_token=" .. Config.VoteToken .. "&ip=" .. playerIP
        
        PerformHttpRequest(
            apiUrl,
            function(statusCode, response, headers)
                if statusCode == 200 then
                    if not response or response == "" then
                        Notifications.Notify(source, L('vote_error'), 'error', 5000)
                        return
                    end
                    
                    local success, data = pcall(json.decode, response)
                    if not success then
                        Notifications.Notify(source, L('vote_error'), 'error', 5000)
                        return
                    end
                    
                    if data and data.success and data.code == 200 then
                        LogPrint("VOTE TROUVÉ pour " .. playerName .. "!")
                        ipVerifiees[playerIP] = os.time()
                        DonnerRecompense(source, citizenid, playerName, playerIP, 'manual')
                    else
                        local errorMsg = data.message or L('vote_not_found')
                        Notifications.Notify(source, errorMsg, 'error', 5000)
                    end
                elseif statusCode == 404 then
                    Notifications.Notify(source, L('vote_not_found'), 'error', 5000)
                else
                    Notifications.Notify(source, L('vote_error'), 'error', 5000)
                end
            end,
            'GET',
            '',
            {['Content-Type'] = 'application/json'}
        )
    end)
end)

-- ═══════════════════════════════════════════════════════════
-- COMMANDES / COMMANDS
-- ═══════════════════════════════════════════════════════════

if Config.Framework == 'qb-core' or Config.Framework == 'qbx_core' then
    QBCore.Commands.Add(Config.Commands.forceVote, L('command_forcervote'), {{name = 'id', help = L('command_forcervote_arg')}}, true, function(source, args)
        local playerId = tonumber(args[1])
        local adminName = GetPlayerName(source)
        
        LogPrint("/forcervote par " .. adminName .. " pour ID " .. playerId)
        
        local player = QBCore.Functions.GetPlayer(playerId)
        
        if not player then
            Notifications.Notify(source, L('player_not_found'), 'error')
            return
        end
        
        local targetName = GetPlayerName(playerId)
        local citizenid = player.PlayerData.citizenid
        local playerEndpoint = GetPlayerEndpoint(playerId)
        local playerIP = playerEndpoint:match("([^:]+)")
        
        player.Functions.AddMoney(Config.RewardType, Config.RewardAmount, 'Vote Reward (Forced)')
        
        MySQL.Async.insert('INSERT INTO vote_rewards (citizenid, player_name, ip_address, reward_amount, reward_type, vote_source) VALUES (@citizenid, @player_name, @ip_address, @reward_amount, @reward_type, @vote_source)', {
            ['@citizenid'] = citizenid,
            ['@player_name'] = targetName,
            ['@ip_address'] = playerIP,
            ['@reward_amount'] = Config.RewardAmount,
            ['@reward_type'] = Config.RewardType,
            ['@vote_source'] = 'forced'
        })
        
        LogPrint("Vote forcé: $" .. Config.RewardAmount .. " donné à " .. targetName)
        
        Notifications.Notify(playerId, L('vote_forced', Config.RewardAmount), 'success', Config.NotificationDuration)
        Notifications.Notify(source, L('reward_given', targetName), 'success')
        
        local discordMessage = "**Admin:** " .. adminName .. "\n" ..
                              "**Joueur:** " .. targetName .. " (" .. citizenid .. ")\n" ..
                              "**Récompense:** $" .. Config.RewardAmount
        
        EnvoyerDiscord("⚠️ Vote forcé par admin", discordMessage, Config.DiscordColors.warning)
    end, Config.AdminPermission)
    
    -- Callback pour debug
    QBCore.Functions.CreateCallback('vote:server:getPlayerVoteInfo', function(source, cb)
        local player = QBCore.Functions.GetPlayer(source)
        if not player then 
            cb(nil)
            return 
        end
        
        local citizenid = player.PlayerData.citizenid
        
        MySQL.Async.fetchAll('SELECT COUNT(*) as total, MAX(claimed_at) as last_vote FROM vote_rewards WHERE citizenid = @citizenid', {
            ['@citizenid'] = citizenid
        }, function(result)
            if result and result[1] then
                cb({
                    citizenid = citizenid,
                    totalVotes = result[1].total,
                    lastVote = result[1].last_vote
                })
            else
                cb(nil)
            end
        end)
    end)
elseif Config.Framework == 'esx' then
    ESX.RegisterCommand(Config.Commands.forceVote, Config.AdminPermission, function(xPlayer, args, showError)
        local playerId = tonumber(args.id)
        local adminName = GetPlayerName(xPlayer.source)
        
        LogPrint("/forcervote par " .. adminName .. " pour ID " .. playerId)
        
        local player = ESX.GetPlayerFromId(playerId)
        
        if not player then
            Notifications.Notify(xPlayer.source, L('player_not_found'), 'error')
            return
        end
        
        local targetName = GetPlayerName(playerId)
        local citizenid = player.identifier
        local playerEndpoint = GetPlayerEndpoint(playerId)
        local playerIP = playerEndpoint:match("([^:]+)")
        
        if Config.RewardType == 'cash' then
            player.addMoney(Config.RewardAmount)
        else
            player.addAccountMoney('bank', Config.RewardAmount)
        end
        
        MySQL.Async.insert('INSERT INTO vote_rewards (citizenid, player_name, ip_address, reward_amount, reward_type, vote_source) VALUES (@citizenid, @player_name, @ip_address, @reward_amount, @reward_type, @vote_source)', {
            ['@citizenid'] = citizenid,
            ['@player_name'] = targetName,
            ['@ip_address'] = playerIP,
            ['@reward_amount'] = Config.RewardAmount,
            ['@reward_type'] = Config.RewardType,
            ['@vote_source'] = 'forced'
        })
        
        LogPrint("Vote forcé: $" .. Config.RewardAmount .. " donné à " .. targetName)
        
        Notifications.Notify(playerId, L('vote_forced', Config.RewardAmount), 'success', Config.NotificationDuration)
        Notifications.Notify(xPlayer.source, L('reward_given', targetName), 'success')
        
        local discordMessage = "**Admin:** " .. adminName .. "\n" ..
                              "**Joueur:** " .. targetName .. " (" .. citizenid .. ")\n" ..
                              "**Récompense:** $" .. Config.RewardAmount
        
        EnvoyerDiscord("⚠️ Vote forcé par admin", discordMessage, Config.DiscordColors.warning)
    end, true, {help = L('command_forcervote'), validate = true, arguments = {
        {name = 'id', help = L('command_forcervote_arg'), type = 'number'}
    }})
end

-- ═══════════════════════════════════════════════════════════
-- INITIALISATION / INITIALIZATION
-- ═══════════════════════════════════════════════════════════

Citizen.CreateThread(function()
    InitialiserDatabase()
    
    Citizen.Wait(1000)
    
    LogPrint("========================================")
    LogPrint(L('system_loaded'))
    LogPrint("Framework: " .. Config.Framework)
    LogPrint("Notifications: " .. Config.NotificationSystem)
    LogPrint("Langue: " .. Config.Locale)
    LogPrint("Token: " .. Config.VoteToken)
    LogPrint("Intervalle: " .. (Config.CheckInterval / 1000) .. "s")
    LogPrint("Récompense: $" .. Config.RewardAmount .. " (" .. Config.RewardType .. ")")
    LogPrint("Debug: " .. (Config.Debug and "ACTIVÉ" or "DÉSACTIVÉ"))
    LogPrint("========================================")
end)
