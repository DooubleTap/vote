local QBCore = exports['qb-core']:GetCoreObject()

-- ═══════════════════════════════════════════════════════════
-- SYSTÈME DE NOTIFICATIONS UNIVERSEL / UNIVERSAL NOTIFICATION SYSTEM
-- ═══════════════════════════════════════════════════════════

Notifications = {}

-- ═══════════════════════════════════════════════════════════
-- CÔTÉ SERVEUR / SERVER SIDE
-- ═══════════════════════════════════════════════════════════

if IsDuplicityVersion() then
    
    function Notifications.Notify(source, message, type, duration)
        duration = duration or Config.NotificationDuration
        
        if Config.NotificationSystem == 'qbcore' then
            TriggerClientEvent('QBCore:Notify', source, message, type, duration)
            
        elseif Config.NotificationSystem == 'ox_lib' then
            TriggerClientEvent('ox_lib:notify', source, {
                title = 'Vote Top-Serveurs',
                description = message,
                type = type,
                duration = duration
            })
            
        elseif Config.NotificationSystem == 'esx' then
            TriggerClientEvent('esx:showNotification', source, message)
            
        elseif Config.NotificationSystem == 'okok' then
            TriggerClientEvent('okokNotify:Alert', source, 'Vote Top-Serveurs', message, duration, type)
            
        elseif Config.NotificationSystem == 'mythic' then
            local mythicType = type == 'success' and 'success' or 
                              type == 'error' and 'error' or 
                              type == 'info' and 'inform' or 'inform'
            TriggerClientEvent('mythic_notify:client:SendAlert', source, {
                type = mythicType,
                text = message,
                length = duration
            })
            
        elseif Config.NotificationSystem == 'custom' then
            -- Ajoutez votre système custom ici / Add your custom system here
            -- TriggerClientEvent('your_custom_notify', source, message, type, duration)
            print("^3[VOTE WARNING]^0 Custom notification system not configured")
            TriggerClientEvent('chat:addMessage', source, {
                color = {255, 255, 0},
                args = {"[Vote]", message}
            })
        end
    end

-- ═══════════════════════════════════════════════════════════
-- CÔTÉ CLIENT / CLIENT SIDE
-- ═══════════════════════════════════════════════════════════

else
    
    function Notifications.Notify(message, type, duration)
        duration = duration or Config.NotificationDuration
        
        if Config.NotificationSystem == 'qbcore' then
            QBCore.Functions.Notify(message, type, duration)
            
        elseif Config.NotificationSystem == 'ox_lib' then
            exports.ox_lib:notify({
                title = 'Vote Top-Serveurs',
                description = message,
                type = type,
                duration = duration
            })
            
        elseif Config.NotificationSystem == 'esx' then
            ESX.ShowNotification(message)
            
        elseif Config.NotificationSystem == 'okok' then
            exports['okokNotify']:Alert('Vote Top-Serveurs', message, duration, type)
            
        elseif Config.NotificationSystem == 'mythic' then
            local mythicType = type == 'success' and 'success' or 
                              type == 'error' and 'error' or 
                              type == 'info' and 'inform' or 'inform'
            exports['mythic_notify']:SendAlert(mythicType, message, duration)
            
        elseif Config.NotificationSystem == 'custom' then
            -- Ajoutez votre système custom ici / Add your custom system here
            -- exports['your_notify']:Notify(message, type, duration)
            print("^3[VOTE WARNING]^0 Custom notification system not configured")
            TriggerEvent('chat:addMessage', {
                color = {255, 255, 0},
                args = {"[Vote]", message}
            })
        end
    end
    
end