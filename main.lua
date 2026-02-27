--[[
    =========================================
    PROJECT: TTNI PREMIUM HUB (FPS FLICK EDITION)
    AUTHOR: ttni131
    STATUS: INJECT READY
    Everything made by ttni131.
    =========================================
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- CONFIGS
local TTNI_Configs = {
    AimAssist = false,
    FlickMode = true, -- Sert kilitlenme açık
    SilentAim = false,
    FOVEnabled = true,
    FOVRadius = 150, -- Flick için biraz daha geniş bir alan iyi olur
    Chams = false,
    MenuKey = Enum.KeyCode.RightShift
}

-- FOV DRAWING
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1
FOVCircle.Color = Color3.fromRGB(0, 255, 255)
FOVCircle.Visible = true
FOVCircle.Radius = TTNI_Configs.FOVRadius

-- GET CLOSEST TARGET
local function GetClosestPlayer()
    local target = nil
    local shortestDistance = math.huge

    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") and v.Character:FindFirstChild("Humanoid").Health > 0 then
            local pos, onScreen = Camera:WorldToViewportPoint(v.Character.HumanoidRootPart.Position)
            if onScreen then
                local distance = (Vector2.new(pos.X, pos.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
                if distance < shortestDistance and distance <= TTNI_Configs.FOVRadius then
                    target = v
                    shortestDistance = distance
                end
            end
        end
    end
    return target
end

-- UI (Minimal & Dark)
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 200, 0, 250)
Main.Position = UDim2.new(0.05, 0, 0.4, 0)
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Main.Active = true
Main.Draggable = true

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, 0, 0, 30)
Title.Text = "TTNI FLICK | ttni131"
Title.TextColor3 = Color3.fromRGB(0, 255, 255)
Title.BackgroundColor3 = Color3.fromRGB(25, 25, 25)

local Layout = Instance.new("UIListLayout", Main)
Layout.Padding = UDim.new(0, 5)

local function CreateToggle(name, callback)
    local btn = Instance.new("TextButton", Main)
    btn.Size = UDim2.new(1, 0, 0, 35)
    btn.Text = name .. ": OFF"
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    
    local state = false
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.Text = name .. ": " .. (state and "ON" or "OFF")
        btn.BackgroundColor3 = state and Color3.fromRGB(0, 100, 200) or Color3.fromRGB(30, 30, 30)
        callback(state)
    end)
end

-- Toggles
CreateToggle("Flick Aim", function(v) TTNI_Configs.AimAssist = v end)
CreateToggle("Silent Aim", function(v) TTNI_Configs.SilentAim = v end)
CreateToggle("Visual Chams", function(v) TTNI_Configs.Chams = v end)

-- FPS FLICK & ENGINE
RunService.Heartbeat:Connect(function()
    FOVCircle.Visible = TTNI_Configs.FOVEnabled
    FOVCircle.Position = Vector2.new(Mouse.X, Mouse.Y + 36)
    FOVCircle.Radius = TTNI_Configs.FOVRadius

    if TTNI_Configs.AimAssist then
        local target = GetClosestPlayer()
        if target and target.Character then
            -- FLICK LOGIC: Lerp yerine doğrudan CFrame odaklaması
            local targetPos = target.Character.HumanoidRootPart.Position
            if TTNI_Configs.FlickMode then
                Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetPos)
            end
        end
    end
end)

-- CHAMS ENGINE
RunService.RenderStepped:Connect(function()
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local highlight = p.Character:FindFirstChild("TTNI_H")
            if TTNI_Configs.Chams then
                if not highlight then
                    highlight = Instance.new("Highlight", p.Character)
                    highlight.Name = "TTNI_H"
                    highlight.FillColor = Color3.fromRGB(0, 255, 255)
                end
            elseif highlight then
                highlight:Destroy()
            end
        end
    end
end)

-- Toggle Menu
UserInputService.InputBegan:Connect(function(i)
    if i.KeyCode == TTNI_Configs.MenuKey then Main.Visible = not Main.Visible end
end)

print("TTNI HUB Inject Edildi! Yapımcı: ttni131")
