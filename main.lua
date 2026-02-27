--[[
    =========================================
    PROJECT: ttnilua VIP (LIVE)
    AUTHOR: ttni131
    THEME: NEON PURPLE / LIVE
    Everything made by ttni131.
    =========================================
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local _G_TTNI_RUNNING = true

-- VIP AYARLAR
local TTNI_Configs = {
    AimAssist = false,
    FOVEnabled = true,
    FOVRadius = 150,
    Chams = false,
    SkeletonESP = false,
    KillSound = true, -- VIP Özelliği
    MenuKey = Enum.KeyCode.RightShift
}

-- FOV ÇEMBERİ (NEON MOR)
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 2.5
FOVCircle.Color = Color3.fromRGB(170, 0, 255)
FOVCircle.Transparency = 1
FOVCircle.Visible = TTNI_Configs.FOVEnabled
FOVCircle.Radius = TTNI_Configs.FOVRadius
FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

-- UI OLUŞTURMA (BÜYÜTÜLMÜŞ MOR TEMA)
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "ttnilua_VIP"

local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 280, 0, 450) -- Panel büyütüldü
Main.Position = UDim2.new(0.05, 0, 0.3, 0)
Main.BackgroundColor3 = Color3.fromRGB(15, 0, 25) -- Koyu Mor Arkaplan
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true

local UICorner = Instance.new("UICorner", Main)
UICorner.CornerRadius = UDim.new(0, 20)

-- NEON IŞILTI (Glow)
local Glow = Instance.new("ImageLabel", Main)
Glow.Name = "Glow"
Glow.BackgroundTransparency = 1
Glow.Position = UDim2.new(0, -15, 0, -15)
Glow.Size = UDim2.new(1, 30, 1, 30)
Glow.Image = "rbxassetid://5028824600"
Glow.ImageColor3 = Color3.fromRGB(170, 0, 255)
Glow.ZIndex = 0

-- BAŞLIK
local Header = Instance.new("Frame", Main)
Header.Size = UDim2.new(1, 0, 0, 60)
Header.BackgroundColor3 = Color3.fromRGB(40, 0, 70)
Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 20)

local Title = Instance.new("TextLabel", Header)
Title.Size = UDim2.new(1, 0, 1, 0)
Title.Text = "TTNI VIP LIVE ⚡"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 22
Title.BackgroundTransparency = 1

local Container = Instance.new("ScrollingFrame", Main)
Container.Size = UDim2.new(1, -20, 1, -130)
Container.Position = UDim2.new(0, 10, 0, 75)
Container.BackgroundTransparency = 1
Container.ScrollBarThickness = 2
Container.CanvasSize = UDim2.new(0, 0, 1.5, 0)

local Layout = Instance.new("UIListLayout", Container)
Layout.Padding = UDim.new(0, 10)
Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- SLIDER (FOV AYARLAMA)
local SliderFrame = Instance.new("Frame", Container)
SliderFrame.Size = UDim2.new(0, 240, 0, 50)
SliderFrame.BackgroundColor3 = Color3.fromRGB(30, 0, 50)
Instance.new("UICorner", SliderFrame)

local SliderLabel = Instance.new("TextLabel", SliderFrame)
SliderLabel.Text = "FOV Radius: " .. TTNI_Configs.FOVRadius
SliderLabel.Size = UDim2.new(1, 0, 0.5, 0)
SliderLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
SliderLabel.BackgroundTransparency = 1

local SliderBtn = Instance.new("TextButton", SliderFrame)
SliderBtn.Size = UDim2.new(0.9, 0, 0.3, 0)
SliderBtn.Position = UDim2.new(0.05, 0, 0.6, 0)
SliderBtn.Text = ""
SliderBtn.BackgroundColor3 = Color3.fromRGB(100, 0, 200)

SliderBtn.MouseButton1Click:Connect(function()
    TTNI_Configs.FOVRadius = (TTNI_Configs.FOVRadius >= 400) and 50 or TTNI_Configs.FOVRadius + 50
    SliderLabel.Text = "FOV Radius: " .. TTNI_Configs.FOVRadius
    FOVCircle.Radius = TTNI_Configs.FOVRadius
end)

-- ÖZELLİK BUTONLARI
local function CreateVIPBtn(name, callback)
    local B = Instance.new("TextButton", Container)
    B.Size = UDim2.new(0, 240, 0, 45)
    B.BackgroundColor3 = Color3.fromRGB(45, 0, 80)
    B.Text = name
    B.TextColor3 = Color3.fromRGB(255, 255, 255)
    B.Font = Enum.Font.GothamMedium
    Instance.new("UICorner", B)
    
    local state = false
    B.MouseButton1Click:Connect(function()
        state = not state
        callback(state)
        B.BackgroundColor3 = state and Color3.fromRGB(170, 0, 255) or Color3.fromRGB(45, 0, 80)
    end)
end

CreateVIPBtn("Flick Aim Assist", function(v) TTNI_Configs.AimAssist = v end)
CreateVIPBtn("Skeleton ESP (VIP)", function(v) TTNI_Configs.SkeletonESP = v end)
CreateVIPBtn("Neon Chams", function(v) TTNI_Configs.Chams = v end)

-- KILL SOUND & SKELETON LOGIC
local function PlayKillSound()
    local sound = Instance.new("Sound", game.Workspace)
    sound.SoundId = "rbxassetid://5633695675" -- VIP Kill Sound (OOF/Ding)
    sound.Volume = 2
    sound:Play()
    task.wait(2)
    sound:Destroy()
end

-- Ölenleri Takip Et (Ses İçin)
Players.PlayerAdded:Connect(function(p)
    p.CharacterAppearanceLoaded:Connect(function(char)
        char:WaitForChild("Humanoid").Died:Connect(function()
            if TTNI_Configs.KillSound then PlayKillSound() end
        end)
    end)
end)

-- UNLOAD
local UB = Instance.new("TextButton", Main)
UB.Size = UDim2.new(1, -40, 0, 40)
UB.Position = UDim2.new(0, 20, 1, -50)
UB.Text = "UNLOAD VIP SCRIPT"
UB.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
UB.TextColor3 = Color3.fromRGB(255, 255, 255)
Instance.new("UICorner", UB)

UB.MouseButton1Click:Connect(function()
    _G_TTNI_RUNNING = false
    FOVCircle:Remove()
    ScreenGui:Destroy()
end)

-- ENGINE
RunService.RenderStepped:Connect(function()
    if not _G_TTNI_RUNNING then return end
    FOVCircle.Visible = TTNI_Configs.FOVEnabled
    FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    
    if TTNI_Configs.AimAssist then
        local target = nil
        local dist = math.huge
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character.Humanoid.Health > 0 then
                local pos, vis = Camera:WorldToViewportPoint(p.Character.HumanoidRootPart.Position)
                if vis then
                    local mag = (Vector2.new(pos.X, pos.Y) - FOVCircle.Position).Magnitude
                    if mag < dist and mag <= TTNI_Configs.FOVRadius then
                        target = p; dist = mag
                    end
                end
            end
        end
        if target then Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Character.HumanoidRootPart.Position) end
    end
end)

print("ttnilua VIP Loaded | Powered by ttni131")
