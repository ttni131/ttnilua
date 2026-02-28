--[[
    =========================================
    PROJECT: ttnilua v11 (SOUND FIXED)
    AUTHOR: ttni131
    Everything made by ttni131.
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
    FOV = 200, -- Biraz daha genişlettim ki rahat yakalasın
}

-- FOV ÇEMBERİ
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 2
FOVCircle.Visible = true
FOVCircle.Transparency = 1

-- SES SİSTEMİ (KESİN ÇALIŞAN YÖNTEM)
local function PlayKillSound()
    -- Mevcut sesi bul veya yeni oluştur
    local sound = Instance.new("Sound")
    sound.SoundId = "rbxassetid://4813331199" -- Meşhur Ding Sesi
    sound.Volume = 10 -- Sesi fulledim
    sound.Parent = game:GetService("SoundService") -- SoundService içine atıyoruz
    sound:Play()
    
    -- Çaldıktan sonra temizle
    sound.Ended:Connect(function()
        sound:Destroy()
    end)
    -- Alternatif temizleme (Ended çalışmazsa diye)
    task.delay(2, function()
        if sound then sound:Destroy() end
    end)
end

-- DUVAR KONTROLÜ
local function IsVisible(part)
    local ignoreList = {LocalPlayer.Character, part.Parent}
    local ray = Ray.new(Camera.CFrame.Position, (part.Position - Camera.CFrame.Position).Unit * 1000)
    local hit = workspace:FindPartOnRayWithIgnoreList(ray, ignoreList)
    return hit == nil or hit:IsDescendantOf(part.Parent)
end

-- AIMBOT (FOV İÇİ VE GÖRÜŞ HATTI)
local function GetClosestTarget()
    local target = nil
    local dist = TTNI.FOV
    
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") and p.Character.Humanoid.Health > 0 then
            local head = p.Character.Head
            local pos, onScreen = Camera:WorldToViewportPoint(head.Position)
            
            if onScreen then
                local mag = (Vector2.new(pos.X, pos.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
                if mag <= dist then
                    if IsVisible(head) then
                        target = head
                        dist = mag
                    end
                end
            end
        end
    end
    return target
end

-- UI TASARIMI
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 350, 0, 500)
Main.Position = UDim2.new(0.35, 0, 0.25, 0)
Main.BackgroundColor3 = Color3.fromRGB(15, 0, 25)
Main.Active = true
Main.Draggable = true
Instance.new("UICorner", Main)

local Header = Instance.new("TextLabel", Main)
Header.Size = UDim2.new(1, 0, 0, 55)
Header.Text = "ttnilua v11.0 OFFICIAL ❄️"
Header.BackgroundColor3 = Color3.fromRGB(80, 0, 150)
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

-- BUTONLAR
local function AddToggle(name, callback)
    local b = Instance.new("TextButton", Container)
    b.Size = UDim2.new(1, 0, 0, 40)
    b.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
    b.Text = name
    b.TextColor3 = Color3.new(1, 1, 1)
    Instance.new("UICorner", b)
    
    local s = false
    b.MouseButton1Click:Connect(function()
        s = not s
        callback(s)
        b.BackgroundColor3 = s and Color3.fromRGB(170, 0, 255) or Color3.fromRGB(30, 30, 45)
    end)
end

AddToggle("Legit Aim Lock (Head)", function(v) TTNI.AimActive = v end)
AddToggle("Full ESP (Highlight)", function(v) TTNI.ESP_Enabled = v end)
AddToggle("Kill Sound (Ding Test)", function(v) 
    TTNI.KillSound = v 
    if v then PlayKillSound() end -- Açınca test için bir kere çalar
end)
AddToggle("3D View (Third Person)", function(v) TTNI.ThirdPerson = v end)
AddToggle("Mevlana (Spin)", function(v) TTNI.Spinbot = v end)

-- ANA DÖNGÜ
RunService.RenderStepped:Connect(function()
    if not _G_TTNI_RUNNING then return end

    FOVCircle.Position = Vector2.new(Mouse.X, Mouse.Y + 36)
    FOVCircle.Radius = TTNI.FOV
    FOVCircle.Color = Color3.fromHSV(tick() % 5 / 5, 1, 1)

    if TTNI.AimActive then
        local t = GetClosestTarget()
        if t then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, t.Position)
        end
    end

    -- ESP
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local h = p.Character:FindFirstChild("TTNI_H")
            if TTNI.ESP_Enabled and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
                if not h then
                    h = Instance.new("Highlight", p.Character)
                    h.Name = "TTNI_H"
                    h.FillColor = Color3.fromRGB(170, 0, 255)
                end
            elseif h then h:Destroy() end
        end
    end

    -- 3D & SPIN
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

-- ÖLÜM TAKİBİ
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
Unload.Text = "EXIT"
Unload.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
Instance.new("UICorner", Unload)
Unload.MouseButton1Click:Connect(function()
    _G_TTNI_RUNNING = false
    FOVCircle:Remove()
    ScreenGui:Destroy()
end)

print("ttnilua v11.0 Loaded. Sound System Updated.")
