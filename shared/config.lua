return {
    photoCoords = vec3(-944.74, -3545.67, 40.61),
    photoHeading = 200.81,

    cameraCoords = vec3(-944.5, -3550.22, 41.07),
    cameraRotation = vector3(0.0, 0.0, 0.0),

    webhookURL = 'ADD_WEBHOOCK_AQUI',

-- Adicione todos os seus modelos aqui
    vehicleModels = {
        'blista',
        'zentorno',
    },
}


-- 🚀 Como Usar no Jogo
-- Antes de tudo de un teleport para essas coordenadas -969.58, -3513.05, 14.15
-- ✅ Iniciar o processo:
-- /screenshot_vehicles

-- O script vai:
-- Spawna o veículo
-- Configura a câmera
-- Tira a screenshot
-- Envia pro Discord via webhook
-- Repete até todos os veículos do config.lua forem processados
-- 🛑 Parar o processo manualmente:
-- /stop_screenshots