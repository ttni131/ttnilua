--[[
    =========================================
    PROJECT: TTNI PREMIUM HUB (FIXED FOV)
    AUTHOR: ttni131
    Everything made by ttni131.
    =========================================
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- CONFIGS
local TTNI_Configs = {
    AimAssist = false,
    SilentAim = false,
    FOVEnabled = true,
    FOVRadius = 150,
    Chams = false,
    MenuKey = Enum.KeyCode.RightShift
}

-- FOV ÇEMBERİNİ MERKEZE SABİTLEME
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1.5
FOVCircle.Color = Color3.fromRGB(0, 255, 255)
FOVCircle.Filled = false
FOVCircle.Transparency = 0.7
FOVCircle.Visible = TTNI_Configs.FOVEnabled
FOVCircle.Radius = TTNI_Configs.FOVRadius
-- Ekranın tam ortası:
FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

-- EKRAN BOYUTU DEĞİŞİNCE FOV'U GÜNCELLE
Camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
    FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
end)

-- EN YAKIN HEDEFİ BUL (MERKEZE GÖRE)
local function GetClosestToCenter()
    local target = nil
    local shortestDistance = math.huge
    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") and v.Character:FindFirstChild("Humanoid").Health > 0 then
            local pos, onScreen = Camera:WorldToViewportPoint(v.Character.HumanoidRootPart.Position)
            if onScreen then
                local distance = (Vector2.new(pos.X, pos.Y) - screenCenter).Magnitude
                if distance < shortestDistance and distance <= TTNI_Configs.FOVRadius then
                    target = v
                    shortestDistance = distance
                end
            end
        end
    end
    return target
end

-- UI TASARIMI (ttni131 Style)
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 200, 0, 220)
Main.Position = UDim2.new(0.05, 0, 0.4, 0)
Main.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true

local Corner = Instance.new("UICorner", Main)
Corner.CornerRadius = UDim.new(0, 10)

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Text = "TTNI HUB | ttni131"
Title.TextColor3 = Color3.fromRGB(0, 255, 255)
Title.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Title.Font = Enum.Font.GothamBold

local Layout = Instance.new("UIListLayout", Main)
Layout.Padding = UDim.new(0, 5)
Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local function CreateToggle(name, callback)
    local btn = Instance.new("TextButton", Main)
    btn.Size = UDim2.new(0, 180, 0, 35)
    btn.Text = name .. ": OFF"
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.Gotham
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    
    local state = false
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.Text = name .. ": " .. (state and "ON" or "OFF")
        btn.BackgroundColor3 = state and Color3.fromRGB(0, 160, 255) or Color3.fromRGB(30, 30, 30)
        callback(state)
    end)
end

CreateToggle("Flick Aim", function(v) TTNI_Configs.AimAssist = v end)
CreateToggle("Show FOV", function(v) TTNI_Configs.FOVEnabled = v end)
CreateToggle("Visual Chams", function(v) TTNI_Configs.Chams = v end)

-- ANA DÖNGÜ (FLICK & VISUALS)
RunService.RenderStepped:Connect(function()
    FOVCircle.Visible = TTNI_Configs.FOVEnabled
    
    if TTNI_Configs.AimAssist then
        local target = GetClosestToCenter()
        if target and target.Character then
            -- FLICK: Hedef çembere girdiği an kamera oraya kilitlenir
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Character.HumanoidRootPart.Position)
        end
    end

    -- Chams İşleyici
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local h = p.Character:FindFirstChild("TTNI_H")
            if TTNI_Configs.Chams then
                if not h then
                    h = Instance.new("Highlight", p.Character)
                    h.Name = "TTNI_H"
                    h.FillColor = Color3.fromRGB(0, 255, 255)
                end
            elseif h then h:Destroy() end
        end
    end
end)

-- Menü Kapatma
UserInputService.InputBegan:Connect(function(i)
    if i.KeyCode == TTNI_Configs.MenuKey then Main.Visible = not Main.Visible end
end)

print("TTNI HUB by ttni131: Ekran Ortası FOV Aktif!")
