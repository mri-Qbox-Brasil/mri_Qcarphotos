local configCode = LoadResourceFile(GetCurrentResourceName(), "shared/config.lua")
local Config = load(configCode)()

RegisterNetEvent('vehicle-screenshots:sendWebhook')
AddEventHandler('vehicle-screenshots:sendWebhook', function(vehicleName, progress, total)
    local embed = {{
        title = "📸 Screenshot de Veículo",
        description = "**Modelo:** `" .. vehicleName .. "`",
        color = 3447003,
        fields = {{
            name = "Progresso",
            value = progress .. "/" .. total,
            inline = true
        }, {
            name = "Porcentagem",
            value = string.format("%.1f%%", (progress / total) * 100),
            inline = true
        }},
        footer = { text = "Sistema de Screenshots Automáticas" }
    }}

    PerformHttpRequest(Config.webhookURL, function(err)
        if err == 200 or err == 204 then
            print("^2[SERVER] Webhook enviado: " .. vehicleName .. " (" .. progress .. "/" .. total .. ")^7")
        else
            print("^1[SERVER] Erro ao enviar webhook: " .. err .. "^7")
        end
    end, 'POST', json.encode({
        username = "Sistema de Screenshots",
        avatar_url = "https://i.imgur.com/AfFp7pu.png",
        embeds = embed
    }), { ['Content-Type'] = 'application/json' })
end)
