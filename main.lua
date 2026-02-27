--[[
    =========================================
    PROJECT: TTNI OFFICIAL HUB (WINTER EDITION)
    AUTHOR: ttni131
    THEME: SNOWY / FROST
    Everything made by ttni131.
    =========================================
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- CONFIGS
local TTNI_Configs = {
    AimAssist = false,
    FOVEnabled = true,
    FOVRadius = 150,
    Chams = false,
    MenuKey = Enum.KeyCode.RightShift
}

-- FOV ÇEMBERİ (BUZ MAVİSİ)
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 2
FOVCircle.Color = Color3.fromRGB(180, 240, 255) -- Buz Mavisi
FOVCircle.Filled = false
FOVCircle.Transparency = 0.8
FOVCircle.Visible = TTNI_Configs.FOVEnabled
FOVCircle.Radius = TTNI_Configs.FOVRadius
FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

-- UI OLUŞTURMA (KAR TEMALI)
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "TTNI_Official_Winter"

local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 230, 0, 300)
Main.Position = UDim2.new(0.05, 0, 0.4, 0)
Main.BackgroundColor3 = Color3.fromRGB(10, 20, 30) -- Derin Gece Mavisi
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Main.ClipsDescendants = true

local UICorner = Instance.new("UICorner", Main)
UICorner.CornerRadius = UDim.new(0, 15)

-- Üst Başlık (Snow Header)
local Header = Instance.new("Frame", Main)
Header.Size = UDim2.new(1, 0, 0, 50)
Header.BackgroundColor3 = Color3.fromRGB(200, 230, 255) -- Kar Beyazı/Mavisi
Header.BorderSizePixel = 0

local HeaderCorner = Instance.new("UICorner", Header)
HeaderCorner.CornerRadius = UDim.new(0, 15)

local Title = Instance.new("TextLabel", Header)
Title.Size = UDim2.new(1, 0, 1, 0)
Title.Text = "TTNI OFFICIAL ❄️"
Title.TextColor3 = Color3.fromRGB(10, 40, 70)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.BackgroundTransparency = 1

local SubTitle = Instance.new("TextLabel", Main)
SubTitle.Size = UDim2.new(1, 0, 0, 20)
SubTitle.Position = UDim2.new(0, 0, 0, 55)
SubTitle.Text = "made by ttni131"
SubTitle.TextColor3 = Color3.fromRGB(150, 180, 200)
SubTitle.Font = Enum.Font.GothamItalic
SubTitle.TextSize = 12
SubTitle.BackgroundTransparency = 1

local Container = Instance.new("ScrollingFrame", Main)
Container.Size = UDim2.new(1, -20, 1, -90)
Container.Position = UDim2.new(0, 10, 0, 80)
Container.BackgroundTransparency = 1
Container.ScrollBarThickness = 2
Container.CanvasSize = UDim2.new(0, 0, 1.2, 0)

local Layout = Instance.new("UIListLayout", Container)
Layout.Padding = UDim.new(0, 10)
Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- KAR TEMALI BUTON FONKSİYONU
local function CreateTog(name, callback)
    local Button = Instance.new("TextButton", Container)
    Button.Size = UDim2.new(0, 190, 0, 40)
    Button.BackgroundColor3 = Color3.fromRGB(25, 45, 65)
    Button.Text = "  " .. name
    Button.TextColor3 = Color3.fromRGB(200, 230, 255)
    Button.Font = Enum.Font.GothamMedium
    Button.TextSize = 14
    Button.TextXAlignment = Enum.TextXAlignment.Left
    
    local BCorner = Instance.new("UICorner", Button)
    BCorner.CornerRadius = UDim.new(0, 8)

    local StatusInd = Instance.new("Frame", Button)
    StatusInd.Size = UDim2.new(0, 10, 0, 10)
    StatusInd.Position = UDim2.new(1, -25, 0.5, -5)
    StatusInd.BackgroundColor3 = Color3.fromRGB(255, 50, 50) -- Kapalıyken kırmızı
    Instance.new("UICorner", StatusInd).CornerRadius = UDim.new(1, 0)

    local enabled = false
    Button.MouseButton1Click:Connect(function()
        enabled = not enabled
        callback(enabled)
        
        -- Yumuşak Renk Geçişi (Tween)
        local goal = {}
        goal.BackgroundColor3 = enabled and Color3.fromRGB(0, 180, 255) or Color3.fromRGB(255, 50, 50)
        TweenService:Create(StatusInd, TweenInfo.new(0.3), goal):Play()
    end)
end

-- ÖZELLİKLERİ EKLE
CreateTog("Flick Aim Assist", function(v) TTNI_Configs.AimAssist = v end)
CreateTog("Show Frost FOV", function(v) TTNI_Configs.FOVEnabled = v end)
CreateTog("Winter Chams", function(v) TTNI_Configs.Chams = v end)

-- LOGIC SİSTEMİ
local function GetClosestTarget()
    local target = nil
    local shortestDist = math.huge
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            if p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
                local pos, onScreen = Camera:WorldToViewportPoint(p.Character.HumanoidRootPart.Position)
                if onScreen then
                    local dist = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                    if dist < shortestDist and dist <= TTNI_Configs.FOVRadius then
                        target = p
                        shortestDist = dist
                    end
                end
            end
        end
    end
    return target
end

RunService.RenderStepped:Connect(function()
    FOVCircle.Visible = TTNI_Configs.FOVEnabled
    FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    
    if TTNI_Configs.AimAssist then
        local t = GetClosestTarget()
        if t then
            -- TTNI Sert Flick
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, t.Character.HumanoidRootPart.Position)
        end
    end

    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local h = p.Character:FindFirstChild("TTNI_Ice")
            if TTNI_Configs.Chams then
                if not h then
                    h = Instance.new("Highlight", p.Character)
                    h.Name = "TTNI_Ice"
                    h.FillColor = Color3.fromRGB(150, 230, 255) -- Buz Rengi
                    h.OutlineColor = Color3.fromRGB(255, 255, 255)
                end
            elseif h then h:Destroy() end
        end
    end
end)

-- Menü Aç/Kapat
UserInputService.InputBegan:Connect(function(k)
    if k.KeyCode == TTNI_Configs.MenuKey then Main.Visible = not Main.Visible end
end)

-- Giriş Bildirimi
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "TTNI OFFICIAL ❄️",
    Text = "Winter Hub Loaded. Welcome, ttni131!",
    Duration = 5
})
