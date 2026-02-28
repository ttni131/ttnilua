--[[
    =========================================
    PROJECT: ttnilua v13 (NEVERLOSE FULL INJECT)
    AUTHOR: ttni131
    Everything made by ttni131.
    -----------------------------------------
    DESCRIPTION: Neverlose source fully 
    connected to ttnilua rage engine.
    =========================================
]]

-- NEVERLOSE LOAD
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/CludeHub/NEVERLOSE/refs/heads/main/NEVERLOSE-CS2-NEW-SOURCE.lua"))()
local Window = Library:AddWindow("ttnilua | NEVERLOSE", "rbxassetid://118608145176297", "Counter Strike 2 Mode")

-- SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- MASTER CONFIG (Neverlose Settings Connection)
local Settings = {
    Enabled = false,
    SilentAim = false,
    FOV = 180,
    WallCheck = true,
    HitChance = 60,
    TargetPart = "Head",
    Spinbot = false,
    ESP = false,
    KillSound = true
}

-- [RAGE TAB]
Window:AddTabLabel("Aimbot")
local RageTab = Window:AddTab("Rage", "crosshair")
local MainSection = RageTab:AddSection("MAIN", "left")

MainSection:AddToggle("Enabled", false, function(v) Settings.Enabled = v end)

local silentToggle = MainSection:AddToggle("Silent Aim", false, function(v) Settings.SilentAim = v end)
silentToggle:AddSettings():AddToggle("Perfect Silent Aim", false, function(val) end)

MainSection:AddToggle("Aim Through Walls", true, function(v) Settings.WallCheck = not v end)

MainSection:AddSlider("Field of View", 1, 180, 180, function(v) Settings.FOV = v end, "°")

-- [SELECTION SECTION]
local SelectionSection = RageTab:AddSection("SELECTION", "left")
SelectionSection:AddDropdown("Target Hitbox", {"Head", "HumanoidRootPart", "Random"}, function(v) 
    Settings.TargetPart = v 
end)

SelectionSection:AddSlider("Hit Chance", 0, 100, 60, function(v) Settings.HitChance = v end, "%")

-- [ANTI-AIM SECTION]
local AntiAimSection = RageTab:AddSection("ANTI-AIM", "right")
AntiAimSection:AddToggle("Enabled (Mevlana)", false, function(v) Settings.Spinbot = v end)

local accYaw = AntiAimSection:AddAccordion("Yaw Direction")
accYaw:AddDropdown("Mode", {"Backwards", "Spin", "Random"}, function(v) end)

-- [VISUALS TAB]
local VisualsTab = Window:AddTab("Visuals", "camera")
local ESPSection = VisualsTab:AddSection("ESP", "left")
ESPSection:AddToggle("Enabled", false, function(v) Settings.ESP = v end)
ESPSection:AddToggle("Kill Sounds", true, function(v) Settings.KillSound = v end)

-- [ENGINE - CORE LOGIC]
local function GetClosestTarget()
    local target = nil
    local maxDist = Settings.FOV
    
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild(Settings.TargetPart) then
            local part = p.Character[Settings.TargetPart]
            local hum = p.Character:FindFirstChild("Humanoid")
            
            if hum and hum.Health > 0 then
                local pos, onScreen = Camera:WorldToViewportPoint(part.Position)
                if onScreen then
                    local mag = (Vector2.new(pos.X, pos.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
                    if mag <= maxDist then
                        -- Wall Check Logic
                        if not Settings.WallCheck then
                            target = part; maxDist = mag
                        else
                            local ray = Ray.new(Camera.CFrame.Position, (part.Position - Camera.CFrame.Position).Unit * 1000)
                            local hit = workspace:FindPartOnRayWithIgnoreList(ray, {LocalPlayer.Character, p.Character})
                            if not hit then target = part; maxDist = mag end
                        end
                    end
                end
            end
        end
    end
    return target
end

-- DING SOUND ENGINE
local function PlayKillSound()
    local s = Instance.new("Sound", game:GetService("SoundService"))
    s.SoundId = "rbxassetid://4813331199"
    s.Volume = 5
    s:Play()
    game:GetService("Debris"):AddItem(s, 2)
end

-- MAIN LOOP
RunService.RenderStepped:Connect(function()
    -- Rage/Aimbot Execution
    if Settings.Enabled then
        local t = GetClosestTarget()
        if t then
            -- Hit Chance Check (0-100)
            if math.random(1, 100) <= Settings.HitChance then
                if Settings.SilentAim then
                    -- Silent Aim (Mermi yönlendirme altyapısı buraya gelir)
                    Camera.CFrame = CFrame.new(Camera.CFrame.Position, t.Position)
                else
                    Camera.CFrame = CFrame.new(Camera.CFrame.Position, t.Position)
                end
            end
        end
    end

    -- Anti-Aim (Mevlana) Execution
    if Settings.Spinbot and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        LocalPlayer.Character.HumanoidRootPart.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.Angles(0, math.rad(50), 0)
    end

    -- ESP Execution
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local highlight = p.Character:FindFirstChild("NL_ESP")
            if Settings.ESP and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
                if not highlight then
                    highlight = Instance.new("Highlight", p.Character)
                    highlight.Name = "NL_ESP"
                    highlight.FillColor = Color3.fromRGB(0, 160, 255) -- Neverlose Blue
                end
            elseif highlight then highlight:Destroy() end
        end
    end
end)

-- KILL SOUND TRIGGER
Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function(char)
        char:WaitForChild("Humanoid").Died:Connect(function()
            if Settings.KillSound then PlayKillSound() end
        end)
    end)
end)

Window:LoadSavedConfig()
print("ttnilua v13 FULL INJECTED | NEVERLOSE CORE ACTIVE")
