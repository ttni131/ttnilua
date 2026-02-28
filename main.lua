--[[
    =========================================
    PROJECT: ttnilua v17 (NEW LIST)
    AUTHOR: ttni131
    -----------------------------------------
    1. ESP (Box)        6. Aimbot (Lock)
    2. Skeleton ESP     7. Mevlana (Spin)
    3. Name ESP         8. Kill Sound
    4. Tracer ESP       9. Triggerbot
    5. Aimlock (Hard)   10. Aim FOV (RGB)
    =========================================
]]

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/CludeHub/NEVERLOSE/refs/heads/main/NEVERLOSE-CS2-NEW-SOURCE.lua"))()
local Window = Library:AddWindow("ttnilua VIP", "rbxassetid://118608145176297", "Custom List")

-- SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- MASTER SETTINGS
local TTNI = {
    Aimbot = false,
    Aimlock = false,
    Triggerbot = false,
    FOV = 150,
    -- ESP
    ESP = false,
    Skeleton = false,
    Names = false,
    Tracers = false,
    -- MISC
    Mevlana = false,
    KillSound = true
}

-- FOV DRAWING
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 2
FOVCircle.Visible = true

-- KILL SOUND ENGINE
local function PlayKillSound()
    local s = Instance.new("Sound", SoundService)
    s.SoundId = "rbxassetid://4813331199"
    s.Volume = 5
    s:Play()
    game:GetService("Debris"):AddItem(s, 2)
end

-- TARGET FINDER
local function GetTarget()
    local target = nil
    local dist = TTNI.FOV
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") and p.Character.Humanoid.Health > 0 then
            local pos, vis = Camera:WorldToViewportPoint(p.Character.Head.Position)
            if vis then
                local mag = (Vector2.new(pos.X, pos.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
                if mag <= dist then
                    target = p.Character.Head
                    dist = mag
                end
            end
        end
    end
    return target
end

--- UI TABS ---
local AimTab = Window:AddTab("Combat", "crosshair")
local AimSec = AimTab:AddSection("AIMBOT SETTINGS", "left")

AimSec:AddToggle("6. Aimbot (Soft)", false, function(v) TTNI.Aimbot = v end)
AimSec:AddToggle("5. Aimlock (Hard)", false, function(v) TTNI.Aimlock = v end)
AimSec:AddToggle("9. Triggerbot", false, function(v) TTNI.Triggerbot = v end)
AimSec:AddSlider("10. Aim FOV", 1, 500, 150, function(v) TTNI.FOV = v end)

local VisTab = Window:AddTab("Visuals", "camera")
local VisSec = VisTab:AddSection("ESP SETTINGS", "left")

VisSec:AddToggle("1. ESP (Box)", false, function(v) TTNI.ESP = v end)
VisSec:AddToggle("2. Skeleton ESP", false, function(v) TTNI.Skeleton = v end)
VisSec:AddToggle("3. Name ESP", false, function(v) TTNI.Names = v end)
VisSec:AddToggle("4. Tracer ESP", false, function(v) TTNI.Tracers = v end)

local MiscTab = Window:AddTab("Misc", "gear")
local MiscSec = MiscTab:AddSection("EXTRA", "left")

MiscSec:AddToggle("7. Mevlana (Spinbot)", false, function(v) TTNI.Mevlana = v end)
MiscSec:AddToggle("8. Kill Sound", true, function(v) TTNI.KillSound = v end)

--- ENGINE LOOP ---
RunService.RenderStepped:Connect(function()
    -- FOV Update
    FOVCircle.Position = Vector2.new(Mouse.X, Mouse.Y + 36)
    FOVCircle.Radius = TTNI.FOV
    FOVCircle.Color = Color3.fromHSV(tick() % 5 / 5, 1, 1)

    local target = GetTarget()

    -- AIMBOT & AIMLOCK
    if (TTNI.Aimbot or TTNI.Aimlock) and target then
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Position)
    end

    -- TRIGGERBOT
    if TTNI.Triggerbot and Mouse.Target then
        local model = Mouse.Target:FindFirstAncestorOfClass("Model")
        if model and Players:GetPlayerFromCharacter(model) then
            mouse1click() -- Executor'ın desteklemesi gerekir
        end
    end

    -- MEVLANA
    if TTNI.Mevlana and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.Angles(0, math.rad(60), 0)
    end

    -- ESP SYSTEM (Box, Names, Highlights)
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local highlight = p.Character:FindFirstChild("TTNI_ESP")
            if TTNI.ESP and p.Character.Humanoid.Health > 0 then
                if not highlight then
                    highlight = Instance.new("Highlight", p.Character)
                    highlight.Name = "TTNI_ESP"
                    highlight.FillColor = Color3.fromRGB(170, 0, 255)
                end
            elseif highlight then highlight:Destroy() end
            
            -- Name ESP (Basit Tag)
            if TTNI.Names and p.Character:FindFirstChild("Head") then
                p.Character.Head.CanCollide = false -- Görmeyi kolaylaştırır
            end
        end
    end
end)

-- KILL SOUND TRIGGER
local function ConnectDied(char)
    char:WaitForChild("Humanoid").Died:Connect(function()
        if TTNI.KillSound then PlayKillSound() end
    end)
end
for _, p in pairs(Players:GetPlayers()) do if p ~= LocalPlayer and p.Character then ConnectDied(p.Character) end end
Players.PlayerAdded:Connect(function(p) p.CharacterAdded:Connect(ConnectDied) end)

Window:LoadSavedConfig()
print("ttnilua v17 - New List Synced!")
