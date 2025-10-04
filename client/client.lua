-- Script para gerar screenshots automáticas de veículos
-- Autor: Sistema de Screenshots para GTA RP
-- Uso: Execute o comando /screenshot_vehicles no jogo

-- Carregar config externa
local configCode = LoadResourceFile(GetCurrentResourceName(), "shared/config.lua")
local Config = load(configCode)()

local vehicleModels = Config.vehicleModels
local photoCoords = Config.photoCoords
local photoHeading = Config.photoHeading
local cameraCoords = Config.cameraCoords
local cameraRotation = Config.cameraRotation
local webhookURL = Config.webhookURL

local currentIndex = 1
local isProcessing = false
local spawnedVehicle = nil
local currentCamera = nil

function DeleteCurrentVehicle()
    if spawnedVehicle and DoesEntityExist(spawnedVehicle) then
        print("^5[DEBUG] Deletando veículo anterior...^7")
        DeleteEntity(spawnedVehicle)
        spawnedVehicle = nil
        Wait(200)
    end
end

function SpawnVehicleForPhoto(model)
    local hash = GetHashKey(model)

    if not IsModelInCdimage(hash) or not IsModelAVehicle(hash) then
        print("^1[ERRO] Modelo não encontrado: " .. model .. "^7")
        return false
    end

    print("^5[DEBUG] Carregando modelo: " .. model .. "^7")
    RequestModel(hash)
    local timeout = 0
    while not HasModelLoaded(hash) and timeout < 100 do
        Wait(50)
        timeout = timeout + 1
    end

    if not HasModelLoaded(hash) then
        print("^1[ERRO] Timeout ao carregar: " .. model .. "^7")
        return false
    end

    print("^5[DEBUG] Spawnando veículo: " .. model .. "^7")
    spawnedVehicle = CreateVehicle(hash, photoCoords.x, photoCoords.y, photoCoords.z, photoHeading, false, false)

    if not DoesEntityExist(spawnedVehicle) then
        print("^1[ERRO] Falha ao spawnar: " .. model .. "^7")
        SetModelAsNoLongerNeeded(hash)
        return false
    end

    SetEntityAsMissionEntity(spawnedVehicle, true, true)
    SetVehicleOnGroundProperly(spawnedVehicle)
    PlaceObjectOnGroundProperly(spawnedVehicle)
    SetEntityHeading(spawnedVehicle, photoHeading)
    SetVehicleDoorsLocked(spawnedVehicle, 2)
    SetVehicleDirtLevel(spawnedVehicle, 0.0)
    SetVehicleEngineOn(spawnedVehicle, false, false, false)
    SetModelAsNoLongerNeeded(hash)

    print("^2[SUCESSO] Veículo spawnado: " .. model .. "^7")
    return true
end

function SetupCamera()
    if currentCamera then
        DestroyCam(currentCamera, false)
    end

    currentCamera = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
    SetCamCoord(currentCamera, cameraCoords.x, cameraCoords.y, cameraCoords.z)
    SetCamRot(currentCamera, cameraRotation.x, cameraRotation.y, cameraRotation.z, 2)
    SetCamActive(currentCamera, true)
    RenderScriptCams(true, false, 0, true, true)

    print("^2[CÂMERA] Câmera configurada^7")
    return currentCamera
end

function DestroyCamera()
    if currentCamera then
        RenderScriptCams(false, false, 0, true, true)
        DestroyCam(currentCamera, false)
        currentCamera = nil
        print("^2[CÂMERA] Câmera desativada^7")
    end
end

function TakeScreenshot(vehicleName)
    print("^5[DEBUG] Aguardando renderização...^7")
    Wait(1500)

    print("^5[DEBUG] Tirando screenshot de: " .. vehicleName .. "^7")

    TriggerServerEvent('vehicle-screenshots:sendWebhook', vehicleName, currentIndex, #vehicleModels)

    exports['screenshot-basic']:requestScreenshotUpload(
        webhookURL,
        'files[]',
        {
            encoding = 'jpg',
            quality = 1.0
        },
        function(data)
            local resp = json.decode(data)
            if resp and resp.attachments then
                print("^2[✓] Screenshot enviada: " .. vehicleName .. "^7")
                print("^3    Progresso: " .. currentIndex .. "/" .. #vehicleModels .. "^7")
                print("^3    Link: " .. resp.attachments[1].proxy_url .. "^7")
            else
                print("^1[✗] Erro ao enviar: " .. vehicleName .. "^7")
            end
        end
    )

    Wait(2000)
end

function ProcessNextVehicle()
    if currentIndex > #vehicleModels then
        print("^2╔════════════════════════════════════════╗^7")
        print("^2║   PROCESSO CONCLUÍDO COM SUCESSO!     ║^7")
        print("^2║   Total: " .. #vehicleModels .. " veículos processados        ║^7")
        print("^2╚════════════════════════════════════════╝^7")

        isProcessing = false
        DeleteCurrentVehicle()
        DestroyCamera()
        return
    end

    local model = vehicleModels[currentIndex]

    print("^6╔════════════════════════════════════════╗^7")
    print("^6║ Progresso: [" .. currentIndex .. "/" .. #vehicleModels .. "]^7")
    print("^6║ Modelo: " .. model .. "^7")
    print("^6╚════════════════════════════════════════╝^7")

    DeleteCurrentVehicle()

    if SpawnVehicleForPhoto(model) then
        TakeScreenshot(model)
        currentIndex = currentIndex + 1
        ProcessNextVehicle()
    else
        print("^3[AVISO] Pulando veículo: " .. model .. "^7")
        currentIndex = currentIndex + 1
        ProcessNextVehicle()
    end
end

RegisterCommand('screenshot_vehicles', function()
    if isProcessing then
        print("^1[ERRO] Processo já está em execução!^7")
        return
    end

    print("^2╔════════════════════════════════════════╗^7")
    print("^2║  INICIANDO SCREENSHOTS AUTOMÁTICAS    ║^7")
    print("^2║  Total de veículos: " .. #vehicleModels .. "^7")
    print("^2╚════════════════════════════════════════╝^7")

    isProcessing = true
    currentIndex = 1
    SetupCamera()

    Citizen.CreateThread(function()
        ProcessNextVehicle()
    end)
end, false)

RegisterCommand('stop_screenshots', function()
    if not isProcessing then
        print("^3[AVISO] Nenhum processo em execução^7")
        return
    end

    print("^1╔════════════════════════════════════════╗^7")
    print("^1║    PROCESSO INTERROMPIDO!              ║^7")
    print("^1║    Parado no veículo: " .. currentIndex .. "/" .. #vehicleModels .. "^7")
    print("^1╚════════════════════════════════════════╝^7")

    isProcessing = false
    DeleteCurrentVehicle()
    DestroyCamera()
end, false)

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        DeleteCurrentVehicle()
        DestroyCamera()
    end
end)

print("^2╔════════════════════════════════════════╗^7")
print("^2║   SCRIPT DE SCREENSHOTS CARREGADO     ║^7")
print("^2╠════════════════════════════════════════╣^7")
print("^2║ /screenshot_vehicles - Iniciar         ║^7")
print("^2║ /stop_screenshots    - Parar           ║^7")
print("^2╚════════════════════════════════════════╝^7")
