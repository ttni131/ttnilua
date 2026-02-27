--[[
    =========================================
    PROJECT: ttnilua ULTIMATE RAGE
    AUTHOR: ttni131
    VERSION: 7.0 (Spinbot & Silent Aim)
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
    SilentAim = false,
    WallCheck = true, -- Duvar arkası kitlenmeme aktif
    Spinbot = false, -- Mevlana
    Bhop = false, -- Bunnyhop
    FOV = 150,
    KillSound = true
}

-- FOV ÇEMBERİ (RGB)
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 2
FOVCircle.Visible = true

-- UI SETUP (MOR NEON DEV PANEL)
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 350, 0, 500)
Main.Position = UDim2.new(0.35, 0, 0.2, 0)
Main.BackgroundColor3 = Color3.fromRGB(10, 0, 20)
Main.Active = true
Main.Draggable = true
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 15)

local Header = Instance.new("TextLabel", Main)
Header.Size = UDim2.new(1, 0, 0, 60)
Header.Text = "ttnilua RAGE v7.0 ⚡"
Header.BackgroundColor3 = Color3.fromRGB(60, 0, 100)
Header.TextColor3 = Color3.new(1, 1, 1)
Header.Font = Enum.Font.GothamBold
Header.TextSize = 22
Instance.new("UICorner", Header)

local Container = Instance.new("ScrollingFrame", Main)
Container.Size = UDim2.new(1, -20, 1, -130)
Container.Position = UDim2.new(0, 10, 0, 70)
Container.BackgroundTransparency = 1
Container.ScrollBarThickness = 2
local Layout = Instance.new("UIListLayout", Container)
Layout.Padding = UDim.new(0, 10)

-- SES FONKSİYONU (Kill Sound)
local function PlayKillSound()
    local s = Instance.new("Sound", workspace)
    s.SoundId = "rbxassetid://4813331199" -- VIP Ding Sesi
    s.Volume = 5
    s:Play()
    task.wait(1)
    s:Destroy()
end

-- DUVAR KONTROLÜ (Visibility Check)
local function IsVisible(part)
    local ray = Ray.new(Camera.CFrame.Position, (part.Position - Camera.CFrame.Position).Unit * 1000)
    local hit = workspace:FindPartOnRayWithIgnoreList(ray, {LocalPlayer.Character, part.Parent})
    return hit == nil
end

-- TARGET SEÇİCİ
local function GetTarget()
    local target = nil
    local dist = TTNI.FOV
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") and p.Character.Humanoid.Health > 0 then
            local head = p.Character.Head
            local pos, vis = Camera:WorldToViewportPoint(head.Position)
            if vis then
                if not TTNI.WallCheck or IsVisible(head) then
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
    b.Text = name .. " [OFF]"
    b.TextColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", b)
    
    local s = false
    b.MouseButton1Click:Connect(function()
        s = not s
        b.Text = name .. (s and " [ON]" or " [OFF]")
        b.BackgroundColor3 = s and Color3.fromRGB(170, 0, 255) or Color3.fromRGB(30, 30, 40)
        callback(s)
    end)
end

-- ÖZELLİKLER
AddToggle("Silent Aim (Görünce Vur)", function(v) TTNI.SilentAim = v end)
AddToggle("Wall Check (Duvar Koruması)", function(v) TTNI.WallCheck = v end)
AddToggle("Spinbot (Mevlana)", function(v) TTNI.Spinbot = v end)
AddToggle("Bunnyhop", function(v) TTNI.Bhop = v end)
AddToggle("Kill Sounds", function(v) TTNI.KillSound = v end)

-- ANA DÖNGÜ (Engine)
RunService.RenderStepped:Connect(function()
    if not _G_TTNI_RUNNING then return end
    
    -- RGB FOV
    FOVCircle.Position = Vector2.new(Mouse.X, Mouse.Y + 36)
    FOVCircle.Radius = TTNI.FOV
    FOVCircle.Color = Color3.fromHSV(tick() % 5 / 5, 1, 1)

    -- SILENT AIM & FLICK
    if TTNI.SilentAim then
        local t = GetTarget()
        if t then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, t.Position)
        end
    end

    -- SPINBOT (Mevlana)
    if TTNI.Spinbot and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.Angles(0, math.rad(50), 0)
    end

    -- BUNNYHOP
    if TTNI.Bhop and UserInputService:IsKeyDown(Enum.KeyCode.Space) and LocalPlayer.Character then
        if LocalPlayer.Character:FindFirstChild("Humanoid") and LocalPlayer.Character.Humanoid.FloorMaterial ~= Enum.Material.Air then
            LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

-- ÖLÜM SESİ TAKİBİ
Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function(c)
        c:WaitForChild("Humanoid").Died:Connect(function()
            if TTNI.KillSound then PlayKillSound() end
        end)
    end)
end)

-- UNLOAD
local Unload = Instance.new("TextButton", Main)
Unload.Size = UDim2.new(1, -40, 0, 40)
Unload.Position = UDim2.new(0, 20, 1, -50)
Unload.Text = "KAPAT (UNLOAD)"
Unload.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
Instance.new("UICorner", Unload)
Unload.MouseButton1Click:Connect(function()
    _G_TTNI_RUNNING = false
    FOVCircle:Remove()
    ScreenGui:Destroy()
end)

print("ttnilua v7.0 RAGE Loaded - Made by ttni131")
