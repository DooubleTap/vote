-- ═══════════════════════════════════════════════════════════
-- CLIENT SIDE - Vote System
-- ═══════════════════════════════════════════════════════════

local QBCore = nil
local ESX = nil

-- Attendre que le framework soit chargé
Citizen.CreateThread(function()
    if Config.Framework == 'qb-core' or Config.Framework == 'qbx_core' then
        QBCore = exports['qb-core']:GetCoreObject()
    elseif Config.Framework == 'esx' then
        ESX = exports['es_extended']:getSharedObject()
    end
end)

-- Variables locales
local voteCheckCooldown = false
local lastVoteCheck = 0

-- ═══════════════════════════════════════════════════════════
-- COMMANDES CLIENT / CLIENT COMMANDS
-- ═══════════════════════════════════════════════════════════

RegisterCommand(Config.Commands.vote, function()
    Notifications.Notify(L('vote_info', Config.RewardAmount), 'primary', 8000)
    Notifications.Notify(L('vote_info_command', Config.Commands.checkVote), 'info', 8000)
end)

RegisterCommand(Config.Commands.checkVote, function()
    local currentTime = GetGameTimer()
    
    -- Cooldown de 5 secondes entre chaque vérification (anti-spam)
    if voteCheckCooldown then
        local timeRemaining = math.ceil((5000 - (currentTime - lastVoteCheck)) / 1000)
        if timeRemaining > 0 then
            Notifications.Notify(L('cooldown_wait', timeRemaining), 'error', 3000)
            return
        end
    end
    
    voteCheckCooldown = true
    lastVoteCheck = currentTime
    
    TriggerServerEvent('vote:server:checkVote')
    
    Citizen.SetTimeout(5000, function()
        voteCheckCooldown = false
    end)
end)

-- ═══════════════════════════════════════════════════════════
-- ÉVÉNEMENTS CLIENT / CLIENT EVENTS
-- ═══════════════════════════════════════════════════════════

RegisterNetEvent('vote:client:rewardReceived', function(amount)
    -- Effet sonore
    if Config.PlaySoundOnReward then
        PlaySoundFrontend(-1, "CONFIRM_BEEP", "HUD_MINI_GAME_SOUNDSET", true)
    end
    
    -- Notification
    Notifications.Notify(L('vote_received', amount), 'success', Config.NotificationDuration)
    
    -- Message dans le chat
    if Config.ShowChatMessage then
        TriggerEvent('chat:addMessage', {
            color = {0, 255, 0},
            multiline = true,
            args = {"[Vote]", L('vote_received', amount)}
        })
    end
end)

-- Rappel pour voter (optionnel)
if Config.VoteReminder then
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(Config.VoteReminderInterval)
            
            Notifications.Notify(L('vote_reminder'), 'primary', 8000)
            Notifications.Notify(L('vote_reminder_command', Config.Commands.vote), 'info', 5000)
        end
    end)
end

-- ═══════════════════════════════════════════════════════════
-- AIDE / HELP
-- ═══════════════════════════════════════════════════════════

RegisterCommand(Config.Commands.voteHelp, function()
    TriggerEvent('chat:addMessage', {
        color = {0, 255, 0},
        multiline = true,
        args = {L('help_title')}
    })
    TriggerEvent('chat:addMessage', {
        args = {"/" .. Config.Commands.vote, L('help_vote')}
    })
    TriggerEvent('chat:addMessage', {
        args = {"/" .. Config.Commands.checkVote, L('help_checkvote')}
    })
end)

-- ═══════════════════════════════════════════════════════════
-- DEBUG (ADMIN SEULEMENT)
-- ═══════════════════════════════════════════════════════════

if Config.Debug then
    RegisterCommand('votedebug', function()
        if Config.Framework == 'qb-core' or Config.Framework == 'qbx_core' then
            if QBCore then
                QBCore.Functions.TriggerCallback('vote:server:getPlayerVoteInfo', function(data)
                    if data then
                        print("=== DEBUG VOTE INFO ===")
                        print("CitizenID: " .. data.citizenid)
                        print("Dernier vote: " .. (data.lastVote or "Jamais"))
                        print("Total votes: " .. (data.totalVotes or 0))
                        print("======================")
                    end
                end)
            end
        end
    end)
end

-- ═══════════════════════════════════════════════════════════
-- INITIALISATION
-- ═══════════════════════════════════════════════════════════

Citizen.CreateThread(function()
    print("^2[Vote Client]^0 " .. L('system_loaded'))
end)
