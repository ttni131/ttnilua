--[[
    =========================================
    PROJECT: ttnilua (SRHUB FULL REMAKE)
    AUTHOR: ttni131
    Everything made by ttni131.
    -----------------------------------------
    FEATURES: Aimbot, ESP, Tracers, RGB FOV, 
    Wall Check, Kill Sounds, FPS Boost.
    =========================================
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- CONFIGS (Videodaki her şey)
local TTNI = {
    Aimbot = { Enabled = false, WallCheck = true, FOV = 150, Smoothness = 1, Part = "Head", RGB = true },
    Visuals = { Box = false, Skeleton = false, Tracers = false, Chams = false },
    Misc = { KillSound = true, FPSBoost = false, JumpPower = 50 },
    Running = true
}

-- FOV DRAWING
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1.5
FOVCircle.Visible = true

-- UI SETUP (SRHUB Style)
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 500, 0, 350)
Main.Position = UDim2.new(0.3, 0, 0.3, 0)
Main.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 6)

-- Sidebar
local Sidebar = Instance.new("Frame", Main)
Sidebar.Size = UDim2.new(0, 130, 1, 0)
Sidebar.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
Instance.new("UICorner", Sidebar)

local Title = Instance.new("TextLabel", Sidebar)
Title.Size = UDim2.new(1, 0, 0, 50)
Title.Text = "ttnilua VIP"
Title.TextColor3 = Color3.fromRGB(170, 0, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 20
Title.BackgroundTransparency = 1

-- Page Container
local PageHolder = Instance.new("Frame", Main)
PageHolder.Position = UDim2.new(0, 140, 0, 10)
PageHolder.Size = UDim2.new(1, -150, 1, -20)
PageHolder.BackgroundTransparency = 1

local Layout = Instance.new("UIListLayout", PageHolder)
Layout.Padding = UDim.new(0, 8)

-- FUNCTIONS
local function CreateToggle(name, callback)
    local btn = Instance.new("TextButton", PageHolder)
    btn.Size = UDim2.new(1, 0, 0, 35)
    btn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    btn.Text = "  " .. name
    btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    btn.Font = Enum.Font.SourceSans
    btn.TextSize = 16
    btn.TextXAlignment = Enum.TextXAlignment.Left
    Instance.new("UICorner", btn)
    
    local state = false
    btn.MouseButton1Click:Connect(function()
        state = not state
        callback(state)
        btn.BackgroundColor3 = state and Color3.fromRGB(50, 0, 100) or Color3.fromRGB(25, 25, 25)
        btn.TextColor3 = state and Color3.new(1,1,1) or Color3.fromRGB(200, 200, 200)
    end)
end

-- FOV SLIDER (MANUEL)
local Slider = Instance.new("TextButton", PageHolder)
Slider.Size = UDim2.new(1, 0, 0, 35)
Slider.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Slider.Text = "Adjust FOV: " .. TTNI.Aimbot.FOV
Instance.new("UICorner", Slider)
Slider.MouseButton1Click:Connect(function()
    TTNI.Aimbot.FOV = TTNI.Aimbot.FOV + 50
    if TTNI.Aimbot.FOV > 500 then TTNI.Aimbot.FOV = 50 end
    Slider.Text = "Adjust FOV: " .. TTNI.Aimbot.FOV
end)

-- CORE FEATURES
CreateToggle("Enable Aimbot (Flick)", function(v) TTNI.Aimbot.Enabled = v end)
CreateToggle("Visibility Check (Wall)", function(v) TTNI.Aimbot.WallCheck = v end)
CreateToggle("Box ESP", function(v) TTNI.Visuals.Box = v end)
CreateToggle("Skeleton ESP", function(v) TTNI.Visuals.Skeleton = v end)
CreateToggle("Tracers (Snaplines)", function(v) TTNI.Visuals.Tracers = v end)
CreateToggle("Kill Sounds (Hitmarker)", function(v) TTNI.Misc.KillSound = v end)

-- AIMBOT LOGIC
local function GetTarget()
    local bestTarget = nil
    local maxDist = TTNI.Aimbot.FOV
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild(TTNI.Aimbot.Part) and p.Character.Humanoid.Health > 0 then
            local part = p.Character[TTNI.Aimbot.Part]
            local pos, onScreen = Camera:WorldToViewportPoint(part.Position)
            if onScreen then
                local mag = (Vector2.new(pos.X, pos.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
                if mag < maxDist then
                    if TTNI.Aimbot.WallCheck then
                        local ray = Ray.new(Camera.CFrame.Position, (part.Position - Camera.CFrame.Position).Unit * 1000)
                        local hit = workspace:FindPartOnRayWithIgnoreList(ray, {LocalPlayer.Character, p.Character})
                        if not hit then bestTarget = part; maxDist = mag end
                    else
                        bestTarget = part; maxDist = mag
                    end
                end
            end
        end
    end
    return bestTarget
end

-- RENDER LOOP
RunService.RenderStepped:Connect(function()
    if not TTNI.Running then return end
    
    -- RGB FOV
    FOVCircle.Radius = TTNI.Aimbot.FOV
    FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    FOVCircle.Color = Color3.fromHSV(tick() % 5 / 5, 1, 1)
    
    if TTNI.Aimbot.Enabled then
        local t = GetTarget()
        if t then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, t.Position)
        end
    end
    
    -- ESP LOGIC (Box/Tracer)
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character.Humanoid.Health > 0 then
            local box = p.Character:FindFirstChild("TTNI_Box")
            if TTNI.Visuals.Box then
                if not box then
                    box = Instance.new("Highlight", p.Character)
                    box.Name = "TTNI_Box"
                    box.FillColor = Color3.fromRGB(170, 0, 255)
                end
            elseif box then box:Destroy() end
        end
    end
end)

-- UNLOAD (SELF DESTRUCT)
local Kill = Instance.new("TextButton", Main)
Kill.Size = UDim2.new(0, 100, 0, 30)
Kill.Position = UDim2.new(1, -110, 1, -40)
Kill.Text = "UNLOAD"
Kill.BackgroundColor3 = Color3.fromRGB(100, 0, 0)
Instance.new("UICorner", Kill)
Kill.MouseButton1Click:Connect(function()
    TTNI.Running = false
    FOVCircle:Remove()
    ScreenGui:Destroy()
end)

print("ttnilua v5.0 Loaded. Everything made by ttni131.")
