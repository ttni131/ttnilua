--[[
    =========================================
    PROJECT: ttnilua ULTIMATE VIP
    AUTHOR: ttni131
    VERSION: 3.0 (Purple RGB Live)
    Everything made by ttni131.
    =========================================
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local _G_TTNI_RUNNING = true

-- AYARLAR
local TTNI_Configs = {
    AimAssist = false,
    WallCheck = true, -- Duvar kontrolü eklendi
    TriggerBot = false,
    FOVEnabled = true,
    FOVRadius = 150,
    ESP_Box = false,
    ESP_Skeleton = false,
    KillSound = true,
    FPSBoost = false,
    MenuKey = Enum.KeyCode.RightShift
}

-- RGB FOV ÇEMBERİ
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 2.5
FOVCircle.Filled = false
FOVCircle.Transparency = 1
FOVCircle.Visible = TTNI_Configs.FOVEnabled
FOVCircle.Radius = TTNI_Configs.FOVRadius

-- UI OLUŞTURMA
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "ttnilua_Ultimate"

local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 300, 0, 520) -- Menü daha da büyütüldü
Main.Position = UDim2.new(0.05, 0, 0.25, 0)
Main.BackgroundColor3 = Color3.fromRGB(15, 0, 30)
Main.Active = true
Main.Draggable = true

local UICorner = Instance.new("UICorner", Main)
UICorner.CornerRadius = UDim.new(0, 15)

-- BAŞLIK
local Header = Instance.new("Frame", Main)
Header.Size = UDim2.new(1, 0, 0, 60)
Header.BackgroundColor3 = Color3.fromRGB(50, 0, 90)
Instance.new("UICorner", Header)

local Title = Instance.new("TextLabel", Header)
Title.Size = UDim2.new(1, 0, 1, 0)
Title.Text = "ttnilua ULTIMATE VIP ⚡"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 20
Title.BackgroundTransparency = 1

-- SCROLL CONTAINER
local Container = Instance.new("ScrollingFrame", Main)
Container.Size = UDim2.new(1, -20, 1, -140)
Container.Position = UDim2.new(0, 10, 0, 70)
Container.BackgroundTransparency = 1
Container.ScrollBarThickness = 2
Container.CanvasSize = UDim2.new(0, 0, 2, 0)

local Layout = Instance.new("UIListLayout", Container)
Layout.Padding = UDim.new(0, 8)
Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- FONKSİYONLAR (SES & ESP)
local function PlayVIPSound()
    local s = Instance.new("Sound", game.Workspace)
    s.SoundId = "rbxassetid://4813331199" -- Gelişmiş Hitmark Sesi
    s.Volume = 3
    s:Play()
    task.wait(1.5)
    s:Destroy()
end

-- DUVAR KONTROLÜ (Visibility Check)
local function IsVisible(targetPart)
    if not TTNI_Configs.WallCheck then return true end
    local castPoints = {Camera.CFrame.Position, targetPart.Position}
    local ignoreList = {LocalPlayer.Character, targetPart.Parent}
    local ray = Ray.new(Camera.CFrame.Position, (targetPart.Position - Camera.CFrame.Position).Unit * 1000)
    local hit, pos = workspace:FindPartOnRayWithIgnoreList(ray, ignoreList)
    return hit == nil or hit:IsDescendantOf(targetPart.Parent)
end

-- BUTON OLUŞTURUCU
local function AddToggle(name, callback)
    local B = Instance.new("TextButton", Container)
    B.Size = UDim2.new(0, 260, 0, 40)
    B.BackgroundColor3 = Color3.fromRGB(40, 0, 70)
    B.Text = name
    B.TextColor3 = Color3.fromRGB(200, 200, 200)
    B.Font = Enum.Font.Gotham
    Instance.new("UICorner", B)
    
    local act = false
    B.MouseButton1Click:Connect(function()
        act = not act
        callback(act)
        B.BackgroundColor3 = act and Color3.fromRGB(170, 0, 255) or Color3.fromRGB(40, 0, 70)
        B.TextColor3 = act and Color3.new(1,1,1) or Color3.new(0.8,0.8,0.8)
    end)
end

-- MENÜ İÇERİĞİ
AddToggle("Silent Aim (Visible Only)", function(v) TTNI_Configs.AimAssist = v end)
AddToggle("Wall Check (On/Off)", function(v) TTNI_Configs.WallCheck = v end)
AddToggle("Trigger Bot", function(v) TTNI_Configs.TriggerBot = v end)
AddToggle("Skeleton ESP", function(v) TTNI_Configs.ESP_Skeleton = v end)
AddToggle("Box ESP", function(v) TTNI_Configs.ESP_Box = v end)
AddToggle("Kill Sounds", function(v) TTNI_Configs.KillSound = v end)

-- FOV SLIDER (MANUEL)
local Slider = Instance.new("TextButton", Container)
Slider.Size = UDim2.new(0, 260, 0, 40)
Slider.Text = "Adjust FOV: " .. TTNI_Configs.FOVRadius
Slider.BackgroundColor3 = Color3.fromRGB(60, 0, 110)
Instance.new("UICorner", Slider)
Slider.MouseButton1Click:Connect(function()
    TTNI_Configs.FOVRadius = TTNI_Configs.FOVRadius + 50
    if TTNI_Configs.FOVRadius > 500 then TTNI_Configs.FOVRadius = 50 end
    Slider.Text = "Adjust FOV: " .. TTNI_Configs.FOVRadius
    FOVCircle.Radius = TTNI_Configs.FOVRadius
end)

-- UNLOAD (KAPAT)
local UB = Instance.new("TextButton", Main)
UB.Size = UDim2.new(0, 260, 0, 45)
UB.Position = UDim2.new(0.5, -130, 1, -55)
UB.Text = "EXIT CHEAT (UNLOAD)"
UB.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
UB.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", UB)
UB.MouseButton1Click:Connect(function()
    _G_TTNI_RUNNING = false
    FOVCircle:Remove()
    ScreenGui:Destroy()
end)

-- ANA DÖNGÜ (DURMADAN ÇALIŞAN KISIM)
RunService.RenderStepped:Connect(function()
    if not _G_TTNI_RUNNING then return end
    
    -- RGB FOV Animasyonu
    local hue = tick() % 5 / 5
    FOVCircle.Color = Color3.fromHSV(hue, 1, 1)
    FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    FOVCircle.Visible = TTNI_Configs.FOVEnabled

    -- AIMBOT & VISIBILITY
    if TTNI_Configs.AimAssist then
        local target = nil
        local maxDist = math.huge
        
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") and p.Character.Humanoid.Health > 0 then
                local head = p.Character.Head
                local pos, vis = Camera:WorldToViewportPoint(head.Position)
                
                if vis and IsVisible(head) then -- Sadece görünürse
                    local mag = (Vector2.new(pos.X, pos.Y) - FOVCircle.Position).Magnitude
                    if mag < maxDist and mag <= TTNI_Configs.FOVRadius then
                        target = head
                        maxDist = mag
                    end
                end
            end
        end
        
        if target then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Position)
            -- Trigger Bot
            if TTNI_Configs.TriggerBot then
                mouse1click() -- Executor desteğine göre değişir
            end
        end
    end
    
    -- ESP SİSTEMİ (Skeleton/Box)
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character.Humanoid.Health > 0 then
            if TTNI_Configs.ESP_Box then
                if not p.Character:FindFirstChild("TTNI_Box") then
                    local h = Instance.new("Highlight", p.Character)
                    h.Name = "TTNI_Box"
                    h.FillTransparency = 0.5
                    h.FillColor = Color3.fromRGB(170, 0, 255)
                    h.OutlineColor = Color3.new(1,1,1)
                end
            else
                if p.Character:FindFirstChild("TTNI_Box") then p.Character.TTNI_Box:Destroy() end
            end
        end
    end
end)

-- ÖLÜM SESİ TAKİBİ
Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function(char)
        char:WaitForChild("Humanoid").Died:Connect(function()
            if TTNI_Configs.KillSound then PlayVIPSound() end
        end)
    end)
end)

print("ttnilua Ultimate v3.0 | Everything made by ttni131")
