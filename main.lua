--[[
    =========================================
    PROJECT: ttnilua v16 (ULTIMATE FINAL)
    AUTHOR: ttni131
    -----------------------------------------
    FEATURES: Rage Aim, Spinbot, Unload, 
    Kill Sound, Neverlose UI Sync.
    =========================================
]]

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/CludeHub/NEVERLOSE/refs/heads/main/NEVERLOSE-CS2-NEW-SOURCE.lua"))()
local Window = Library:AddWindow("ttnilua VIP", "rbxassetid://118608145176297", "Counter Strike 2")

-- SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

local _G_TTNI_RUNNING = true

-- CORE SETTINGS
local TTNI = {
    Enabled = false,
    FOV = 180,
    Spin = false,
    KillSound = true,
    WallCheck = true,
    TargetPart = "Head"
}

-- SES MOTORU
local function PlayKillSound()
    local s = Instance.new("Sound", SoundService)
    s.SoundId = "rbxassetid://4813331199"
    s.Volume = 5
    s:Play()
    game:GetService("Debris"):AddItem(s, 2)
end

-- RAGE AIMBOT (UZAK MESAFE & TAM KİLİT)
local function GetClosestTarget()
    local target = nil
    local dist = 999999 -- Mesafe sınırsız (Uzak mesafe için)
    local fov_dist = TTNI.FOV
    
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild(TTNI.TargetPart) and p.Character.Humanoid.Health > 0 then
            local part = p.Character[TTNI.TargetPart]
            local pos, vis = Camera:WorldToViewportPoint(part.Position)
            
            if vis then
                local mag = (Vector2.new(pos.X, pos.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
                if mag <= fov_dist then
                    -- Görüş Hattı Kontrolü (Wall Check)
                    if TTNI.WallCheck then
                        local ray = Ray.new(Camera.CFrame.Position, (part.Position - Camera.CFrame.Position).Unit * 2000)
                        local hit = workspace:FindPartOnRayWithIgnoreList(ray, {LocalPlayer.Character, p.Character})
                        if not hit then target = part; fov_dist = mag end
                    else
                        target = part; fov_dist = mag
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

MainSection:AddToggle("Enabled", false, function(v) TTNI.Enabled = v end)

MainSection:AddSlider("Field of View", 1, 500, 180, function(v) TTNI.FOV = v end)

local acc = MainSection:AddAccordion("Hatdogs (Advanced)")
acc:AddToggle("Mevlana (Spinbot)", false, function(v) TTNI.Spin = v end)
acc:AddToggle("Wall Check (Legit)", true, function(v) TTNI.WallCheck = v end)
acc:AddToggle("Kill Sound (Ding)", true, function(v) TTNI.KillSound = v end)

-- [UNLOAD SECTION]
local MiscTab = Window:AddTab("Misc", "gear")
local MiscSection = MiscTab:AddSection("SYSTEM", "left")

MiscSection:AddButton("UNLOAD SCRIPT", function()
    _G_TTNI_RUNNING = false
    task.wait(0.1)
    game.CoreGui:FindFirstChild("NEVERLOSE"):Destroy() -- Paneli siler
    print("ttnilua: Unloaded successfully.")
end)

-- ANA DÖNGÜ (ENGINE)
RunService.RenderStepped:Connect(function()
    if not _G_TTNI_RUNNING then return end

    -- RAGE AIMBOT EXECUTION
    if TTNI.Enabled then
        local t = GetClosestTarget()
        if t then
            -- Smoothing yok, tam kilit!
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, t.Position)
        end
    end

    -- SPINBOT (MEVLANA) EXECUTION
    if TTNI.Spin and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.Angles(0, math.rad(70), 0)
    end
end)

-- KILL SOUND TRIGGER
local function ConnectDied(char)
    local hum = char:WaitForChild("Humanoid", 5)
    if hum then
        hum.Died:Connect(function()
            if TTNI.KillSound and _G_TTNI_RUNNING then PlayKillSound() end
        end)
    end
end

for _, p in pairs(Players:GetPlayers()) do
    if p ~= LocalPlayer and p.Character then ConnectDied(p.Character) end
    p.CharacterAdded:Connect(ConnectDied)
end
Players.PlayerAdded:Connect(function(p) p.CharacterAdded:Connect(ConnectDied) end)

Window:LoadSavedConfig()
print("ttnilua v16: HER SEY CALISIYOR! (Mevlana, Unload, Fixed Aim)")
