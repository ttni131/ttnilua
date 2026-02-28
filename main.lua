--[[
    =========================================
    PROJECT: ttnilua ULTIMATE v10
    AUTHOR: ttni131
    Everything made by ttni131.
    -----------------------------------------
    FEATURES: Legit Aim Lock, FOV Check,
    Wall Check, Kill Sound, Full ESP, 3D View.
    =========================================
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

local _G_TTNI_RUNNING = true

-- AYARLAR
local TTNI = {
    AimActive = false,
    ESP_Enabled = false,
    KillSound = true,
    ThirdPerson = false,
    Spinbot = false,
    FOV = 150, -- Bu dairenin içine girenler hedeftir
}

-- FOV ÇEMBERİ (RGB)
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 2
FOVCircle.Visible = true
FOVCircle.Filled = false
FOVCircle.Transparency = 1

-- KILL SESİ FONKSİYONU
local function PlayKillSound()
    local sound = Instance.new("Sound", game:GetService("SoundService"))
    sound.SoundId = "rbxassetid://4813331199" -- VIP Hitmark/Kill sesi
    sound.Volume = 5
    sound:Play()
    game:GetService("Debris"):AddItem(sound, 2)
end

-- DUVAR KONTROLÜ (Görüş Hizası Kontrolü)
local function IsInLineOfSight(targetPart)
    local ray = Ray.new(Camera.CFrame.Position, (targetPart.Position - Camera.CFrame.Position).Unit * 1000)
    local hit = workspace:FindPartOnRayWithIgnoreList(ray, {LocalPlayer.Character, targetPart.Parent})
    return hit == nil or hit:IsDescendantOf(targetPart.Parent)
end

-- GERÇEK AIMBOT TARGET SEÇİCİ
local function GetClosestTargetInFOV()
    local target = nil
    local dist = TTNI.FOV
    
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") and p.Character.Humanoid.Health > 0 then
            local head = p.Character.Head
            local pos, onScreen = Camera:WorldToViewportPoint(head.Position)
            
            if onScreen then
                -- Mouse ile hedef arasındaki mesafe (FOV Kontrolü)
                local mousePos = Vector2.new(Mouse.X, Mouse.Y)
                local screenPos = Vector2.new(pos.X, pos.Y)
                local magnitude = (screenPos - mousePos).Magnitude
                
                if magnitude <= dist then
                    -- Mesafe farketmeksizin sadece GÖRÜŞ ALANINDAYSA (Duvar arkası değilse)
                    if IsInLineOfSight(head) then
                        target = head
                        dist = magnitude
                    end
                end
            end
        end
    end
    return target
end

-- UI TASARIMI (MOR NEON)
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 350, 0, 500)
Main.Position = UDim2.new(0.35, 0, 0.25, 0)
Main.BackgroundColor3 = Color3.fromRGB(15, 0, 30)
Main.Active = true
Main.Draggable = true
Instance.new("UICorner", Main)

local Header = Instance.new("TextLabel", Main)
Header.Size = UDim2.new(1, 0, 0, 55)
Header.Text = "ttnilua v10.0 OFFICIAL ⚡"
Header.BackgroundColor3 = Color3.fromRGB(60, 0, 110)
Header.TextColor3 = Color3.new(1, 1, 1)
Header.Font = Enum.Font.GothamBold
Header.TextSize = 18
Instance.new("UICorner", Header)

local Container = Instance.new("ScrollingFrame", Main)
Container.Size = UDim2.new(1, -20, 1, -130)
Container.Position = UDim2.new(0, 10, 0, 65)
Container.BackgroundTransparency = 1
Container.ScrollBarThickness = 0
local Layout = Instance.new("UIListLayout", Container)
Layout.Padding = UDim.new(0, 8)

-- BUTON SİSTEMİ
local function AddToggle(name, callback)
    local b = Instance.new("TextButton", Container)
    b.Size = UDim2.new(1, 0, 0, 40)
    b.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    b.Text = name
    b.TextColor3 = Color3.new(1, 1, 1)
    Instance.new("UICorner", b)
    
    local s = false
    b.MouseButton1Click:Connect(function()
        s = not s
        callback(s)
        b.BackgroundColor3 = s and Color3.fromRGB(170, 0, 255) or Color3.fromRGB(30, 30, 40)
    end)
end

AddToggle("Legit Aim Lock (FOV Only)", function(v) TTNI.AimActive = v end)
AddToggle("Full ESP (Highlight)", function(v) TTNI.ESP_Enabled = v end)
AddToggle("Kill Sound (Ding)", function(v) TTNI.KillSound = v end)
AddToggle("3D View (Third Person)", function(v) TTNI.ThirdPerson = v end)
AddToggle("Mevlana (Spinbot)", function(v) TTNI.Spinbot = v end)

-- ANA DÖNGÜ
RunService.RenderStepped:Connect(function()
    if not _G_TTNI_RUNNING then return end

    -- RGB FOV ÇEMBERİ
    FOVCircle.Position = Vector2.new(Mouse.X, Mouse.Y + 36)
    FOVCircle.Radius = TTNI.FOV
    FOVCircle.Color = Color3.fromHSV(tick() % 5 / 5, 1, 1)

    -- AIMBOT KİLİTLENME
    if TTNI.AimActive then
        local target = GetClosestTargetInFOV()
        if target then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Position)
        end
    end

    -- ESP SİSTEMİ
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local highlight = p.Character:FindFirstChild("TTNI_Highlight")
            if TTNI.ESP_Enabled and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
                if not highlight then
                    highlight = Instance.new("Highlight", p.Character)
                    highlight.Name = "TTNI_Highlight"
                    highlight.FillColor = Color3.fromRGB(170, 0, 255)
                    highlight.OutlineColor = Color3.new(1, 1, 1)
                end
            elseif highlight then
                highlight:Destroy()
            end
        end
    end

    -- 3D VIEW & SPINBOT
    if TTNI.ThirdPerson then
        LocalPlayer.CameraMaxZoomDistance = 15
        LocalPlayer.CameraMinZoomDistance = 15
    else
        LocalPlayer.CameraMaxZoomDistance = 0.5
        LocalPlayer.CameraMinZoomDistance = 0.5
    end

    if TTNI.Spinbot and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.Angles(0, math.rad(60), 0)
    end
end)

-- ÖLÜM TAKİBİ (KILL SESİ İÇİN)
Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function(char)
        char:WaitForChild("Humanoid").Died:Connect(function()
            if TTNI.KillSound then PlayKillSound() end
        end)
    end)
end)

-- UNLOAD
local Unload = Instance.new("TextButton", Main)
Unload.Size = UDim2.new(1, -40, 0, 45)
Unload.Position = UDim2.new(0, 20, 1, -55)
Unload.Text = "UNLOAD (EXIT)"
Unload.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
Instance.new("UICorner", Unload)
Unload.MouseButton1Click:Connect(function()
    _G_TTNI_RUNNING = false
    FOVCircle:Remove()
    ScreenGui:Destroy()
end)

print("ttnilua v10.0 Loaded | Kill Sound & Legit Aim Active")
