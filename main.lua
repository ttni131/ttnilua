--[[
    =========================================
    PROJECT: ttnilua ULTIMATE ESP & AIM
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
    ThirdPerson = false,
    Spinbot = false,
    FOV = 150,
    WallCheck = true -- Sadece görüş açındakilere kitlenmesi için her zaman açık tutulabilir
}

-- FOV ÇEMBERİ (RGB)
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 2
FOVCircle.Visible = true

-- UI SETUP (MOR NEON)
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 350, 0, 500)
Main.Position = UDim2.new(0.35, 0, 0.2, 0)
Main.BackgroundColor3 = Color3.fromRGB(15, 0, 25)
Main.Active = true
Main.Draggable = true
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 15)

local Header = Instance.new("TextLabel", Main)
Header.Size = UDim2.new(1, 0, 0, 60)
Header.Text = "ttnilua v9.0 ESP-AIM ⚡"
Header.BackgroundColor3 = Color3.fromRGB(50, 0, 90)
Header.TextColor3 = Color3.new(1, 1, 1)
Header.Font = Enum.Font.GothamBold
Header.TextSize = 20
Instance.new("UICorner", Header)

local Container = Instance.new("ScrollingFrame", Main)
Container.Size = UDim2.new(1, -20, 1, -130)
Container.Position = UDim2.new(0, 10, 0, 70)
Container.BackgroundTransparency = 1
Container.ScrollBarThickness = 0
local Layout = Instance.new("UIListLayout", Container)
Layout.Padding = UDim.new(0, 10)

-- DUVAR KONTROLÜ (Visibility Check)
local function IsVisible(part)
    local castPoints = {Camera.CFrame.Position, part.Position}
    local ignoreList = {LocalPlayer.Character, part.Parent}
    local ray = Ray.new(Camera.CFrame.Position, (part.Position - Camera.CFrame.Position).Unit * 1000)
    local hit, pos = workspace:FindPartOnRayWithIgnoreList(ray, ignoreList)
    return hit == nil or hit:IsDescendantOf(part.Parent)
end

-- TARGET SEÇİCİ (Görüş Açısı Odaklı)
local function GetTarget()
    local target = nil
    local dist = TTNI.FOV
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") and p.Character.Humanoid.Health > 0 then
            local head = p.Character.Head
            local pos, vis = Camera:WorldToViewportPoint(head.Position)
            
            if vis then -- Eğer adam ekrandaysa
                if IsVisible(head) then -- Eğer adam duvar arkası değilse
                    local mag = (Vector2.new(pos.X, pos.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
                    if mag < dist then
                        target = head
                        dist = mag
                    end
                end
            end
        end
    end
    return target
end

-- BUTON SİSTEMİ
local function AddToggle(name, callback)
    local b = Instance.new("TextButton", Container)
    b.Size = UDim2.new(1, 0, 0, 40)
    b.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    b.Text = name
    b.TextColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", b)
    
    local s = false
    b.MouseButton1Click:Connect(function()
        s = not s
        callback(s)
        b.BackgroundColor3 = s and Color3.fromRGB(170, 0, 255) or Color3.fromRGB(30, 30, 40)
    end)
end

AddToggle("Aimbot (Görünce Kitlen)", function(v) TTNI.AimActive = v end)
AddToggle("Full ESP (Box & Highlight)", function(v) TTNI.ESP_Enabled = v end)
AddToggle("3D View (Third Person)", function(v) TTNI.ThirdPerson = v end)
AddToggle("Mevlana (Spinbot)", function(v) TTNI.Spinbot = v end)

-- ANA DÖNGÜ
RunService.RenderStepped:Connect(function()
    if not _G_TTNI_RUNNING then return end

    -- RGB FOV
    FOVCircle.Position = Vector2.new(Mouse.X, Mouse.Y + 36)
    FOVCircle.Radius = TTNI.FOV
    FOVCircle.Color = Color3.fromHSV(tick() % 5 / 5, 1, 1)

    -- AIMBOT LOCK
    if TTNI.AimActive then
        local t = GetTarget()
        if t then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, t.Position)
        end
    end

    -- ESP SİSTEMİ
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local h = p.Character:FindFirstChild("TTNI_ESP")
            if TTNI.ESP_Enabled and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
                if not h then
                    h = Instance.new("Highlight", p.Character)
                    h.Name = "TTNI_ESP"
                    h.FillColor = Color3.fromRGB(170, 0, 255)
                    h.OutlineColor = Color3.new(1, 1, 1)
                    h.FillTransparency = 0.5
                end
            elseif h then
                h:Destroy()
            end
        end
    end

    -- 3D GÖRÜNÜM
    if TTNI.ThirdPerson then
        LocalPlayer.CameraMaxZoomDistance = 12
        LocalPlayer.CameraMinZoomDistance = 12
    else
        LocalPlayer.CameraMaxZoomDistance = 0.5
        LocalPlayer.CameraMinZoomDistance = 0.5
    end

    -- SPINBOT
    if TTNI.Spinbot and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.Angles(0, math.rad(60), 0)
    end
end)

-- UNLOAD
local Unload = Instance.new("TextButton", Main)
Unload.Size = UDim2.new(1, -40, 0, 40)
Unload.Position = UDim2.new(0, 20, 1, -50)
Unload.Text = "UNLOAD"
Unload.BackgroundColor3 = Color3.fromRGB(120, 0, 0)
Instance.new("UICorner", Unload)
Unload.MouseButton1Click:Connect(function()
    _G_TTNI_RUNNING = false
    FOVCircle:Remove()
    ScreenGui:Destroy()
end)

print("ttnilua v9.0 | ESP & Legit Aim Loaded!")
