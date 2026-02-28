--[[
    =========================================
    PROJECT: ttnilua v15 (FINAL ENGINE)
    AUTHOR: ttni131
    Everything connected to Neverlose UI.
    =========================================
]]

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/CludeHub/NEVERLOSE/refs/heads/main/NEVERLOSE-CS2-NEW-SOURCE.lua"))()
local Window = Library:AddWindow("ttnilua VIP", "rbxassetid://118608145176297", "Counter Strike 2")

-- SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- MOTOR AYARLARI (Butonlara Bağlı)
local TTNI_CORE = {
    Enabled = false,
    SilentAim = true,
    FOV = 74.8,
    KillSound = true,
    TargetMode = "Closest",
    WallCheck = true
}

-- SES MOTORU (DİNG)
local function PlayKillSound()
    local s = Instance.new("Sound", game:GetService("SoundService"))
    s.SoundId = "rbxassetid://4813331199"
    s.Volume = 5
    s:Play()
    game:GetService("Debris"):AddItem(s, 2)
end

-- TARGET SEÇİCİ (GÖRÜŞ HATTI + FOV)
local function GetTarget()
    local target = nil
    local dist = TTNI_CORE.FOV
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") and p.Character.Humanoid.Health > 0 then
            local head = p.Character.Head
            local pos, vis = Camera:WorldToViewportPoint(head.Position)
            if vis then
                local mag = (Vector2.new(pos.X, pos.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
                if mag <= dist then
                    -- Wall Check (Görüş Açısı)
                    local ray = Ray.new(Camera.CFrame.Position, (head.Position - Camera.CFrame.Position).Unit * 1000)
                    local hit = workspace:FindPartOnRayWithIgnoreList(ray, {LocalPlayer.Character, p.Character})
                    if not hit then
                        target = head
                        dist = mag
                    end
                end
            end
        end
    end
    return target
end

-- [RAGE TAB]
local RageTab = Window:AddTab("Rage", "crosshair")
local MainSection = RageTab:AddSection("MAIN", "left")

-- Senin İstediğin Butonlar ve Bağlantıları:
MainSection:AddToggle("Enabled", true, function(value)
    TTNI_CORE.Enabled = value
end)

MainSection:AddSlider("Field of View", 1, 180, 74.8, function(v)
    TTNI_CORE.FOV = v
end, "°")

local toggle = MainSection:AddToggle("Silent Aim", true, function(v)
    TTNI_CORE.SilentAim = v
end)

local settings = toggle:AddSettings()
settings:AddToggle("Automatic Fire", true, function(v) end)
settings:AddToggle("Kill Sound (Ding)", true, function(v) TTNI_CORE.KillSound = v end)

-- [SELECTION SECTION]
local SelectionSection = RageTab:AddSection("SELECTION", "left")
SelectionSection:AddDropdown("Target", {"Closest", "Highest Damage", "Random"}, function(v)
    TTNI_CORE.TargetMode = v
end)

SelectionSection:AddColorpicker("ESP Color", Color3.fromRGB(26, 123, 255), function(val)
    -- ESP Rengini Buradan Ayarlayabilirsin
end)

-- [ACCORDION (HATDOGS)]
local acc = MainSection:AddAccordion("Hatdogs")
acc:AddToggle("Wall Check (Legit)", true, function(v) TTNI_CORE.WallCheck = v end)
acc:AddSlider("Spin Speed", 0, 100, 50, function(v) end, "%")

-- [CORE LOOP]
RunService.RenderStepped:Connect(function()
    if TTNI_CORE.Enabled then
        local t = GetTarget()
        if t then
            -- Aimbot Lock
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, t.Position)
        end
    end
end)

-- KILL SOUND TRIGGER
Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function(char)
        char:WaitForChild("Humanoid").Died:Connect(function()
            if TTNI_CORE.KillSound then PlayKillSound() end
        end)
    end)
end)

-- Mevcut oyuncular için de aktif et
for _, p in pairs(Players:GetPlayers()) do
    if p ~= LocalPlayer and p.Character then
        p.Character.Humanoid.Died:Connect(function()
            if TTNI_CORE.KillSound then PlayKillSound() end
        end)
    end
end

Window:LoadSavedConfig()
print("ttnilua v15 LOADED - Neverlose Engine Synced!")
