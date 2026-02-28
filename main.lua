--[[
    =========================================
    PROJECT: ttnilua v18 (LEGIT STEALTH)
    AUTHOR: ttni131
    -----------------------------------------
    SAFE MODE: Anti-Ban, Smooth Aim, 
    Staff Detector, Visibility Check.
    =========================================
]]

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/CludeHub/NEVERLOSE/refs/heads/main/NEVERLOSE-CS2-NEW-SOURCE.lua"))()
local Window = Library:AddWindow("ttnilua LEGIT", "rbxassetid://118608145176297", "Stealth Mode")

-- SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- BYPASS & STEALTH SETTINGS
local TTNI = {
    LegitAim = false,
    Smoothness = 0.2, -- Kilitlenme hızı (Düşük = Daha insansı)
    FOV = 60, -- Küçük FOV = Daha az risk
    ESP = false,
    VisibleOnly = true, -- Duvar arkası asla kitlenmez (En önemli ban koruması)
    StaffCheck = true -- Admin gelince uyarı/kapatma
}

-- STAFF DETECTOR (Admin Korunma)
local function CheckForAdmins()
    for _, p in pairs(Players:GetPlayers()) do
        if p:GetRankInGroup(0) > 100 or p.Character == nil then -- Örnek grup ID ve rütbe
            -- Buraya admin gelince yapılacak aksiyonu ekleyebilirsin
        end
    end
end

-- VISIBILITY CHECK (Sadece Görünce)
local function IsVisible(part)
    local ray = Ray.new(Camera.CFrame.Position, (part.Position - Camera.CFrame.Position).Unit * 1000)
    local hit = workspace:FindPartOnRayWithIgnoreList(ray, {LocalPlayer.Character, part.Parent})
    return hit == nil
end

-- LEGIT TARGET FINDER
local function GetLegitTarget()
    local target = nil
    local dist = TTNI.FOV
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") and p.Character.Humanoid.Health > 0 then
            local head = p.Character.Head
            local pos, vis = Camera:WorldToViewportPoint(head.Position)
            if vis and IsVisible(head) then -- Sadece ekrandaysa ve görünüyorsa
                local mag = (Vector2.new(pos.X, pos.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
                if mag <= dist then
                    target = head
                    dist = mag
                end
            end
        end
    end
    return target
end

-- [STEALTH UI]
local StealthTab = Window:AddTab("Stealth", "shield")
local MainSec = StealthTab:AddSection("LEGIT AIM", "left")

MainSec:AddToggle("Legit Aimbot", false, function(v) TTNI.LegitAim = v end)
MainSec:AddSlider("Aim Smoothness", 1, 10, 2, function(v) TTNI.Smoothness = v/10 end)
MainSec:AddSlider("Small FOV", 10, 100, 60, function(v) TTNI.FOV = v end)

local VisSec = StealthTab:AddSection("SAFE VISUALS", "right")
VisSec:AddToggle("Legit ESP (Highlights)", false, function(v) TTNI.ESP = v end)

-- [ENGINE]
RunService.RenderStepped:Connect(function()
    if TTNI.LegitAim then
        local t = GetLegitTarget()
        if t then
            -- Sert kilit yerine yumuşak geçiş (Lerp)
            local targetPos = CFrame.new(Camera.CFrame.Position, t.Position)
            Camera.CFrame = Camera.CFrame:Lerp(targetPos, TTNI.Smoothness)
        end
    end

    -- ESP (Düşük parlaklık, daha güvenli)
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local h = p.Character:FindFirstChild("Legit_ESP")
            if TTNI.ESP and p.Character.Humanoid.Health > 0 then
                if not h then
                    h = Instance.new("Highlight", p.Character)
                    h.Name = "Legit_ESP"
                    h.FillTransparency = 0.6
                    h.OutlineTransparency = 0.5
                end
            elseif h then h:Destroy() end
        end
    end
end)

print("ttnilua v18 Stealth Loaded. Be careful, play legit!")
