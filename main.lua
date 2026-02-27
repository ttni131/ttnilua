--[[
    TTNI PREMIUM COMBAT & VISUALS
    Everything made by TTNI.
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- Ayarlar Tablosu (Panelle Bağlayacağız)
_G.TTNI_Configs = {
    AimAssist = false,
    SilentAim = false,
    FOVEnabled = false,
    FOVRadius = 100,
    ESPEnabled = false,
    Boxes = false,
    Health = false,
    Chams = false
}

-- FOV Çemberi Çizimi
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1
FOVCircle.Color = Color3.fromRGB(255, 255, 255)
FOVCircle.Filled = false

-- En Yakın Düşmanı Bulma Fonksiyonu (Aim & Silent Aim İçin)
local function GetClosestPlayer()
    local target = nil
    local shortestDistance = math.huge

    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
            local pos, onScreen = Camera:WorldToViewportPoint(v.Character.HumanoidRootPart.Position)
            if onScreen then
                local mousePos = Vector2.new(Mouse.X, Mouse.Y)
                local distance = (Vector2.new(pos.X, pos.Y) - mousePos).Magnitude
                
                if distance < shortestDistance and distance <= (_G.TTNI_Configs.FOVEnabled and _G.TTNI_Configs.FOVRadius or math.huge) then
                    target = v
                    shortestDistance = distance
                end
            end
        end
    end
    return target
end
