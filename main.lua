--[[
    =========================================
    PROJECT: TTNI PREMIUM HUB (ROBLOX)
    AUTHOR: TTNI
    STATUS: FULLY FUNCTIONAL
    Everything made by TTNI.
    =========================================
]]

-- SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- CONFIGS (TTNI SETTINGS)
local TTNI_Configs = {
    AimAssist = false,
    SilentAim = false,
    FOVEnabled = true,
    FOVRadius = 100,
    FOVColor = Color3.fromRGB(255, 255, 255),
    ESPEnabled = false,
    Boxes = false,
    Health = false,
    Chams = false,
    MenuKey = Enum.KeyCode.RightShift
}

-- FOV CIRCLE DRAWING
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1
FOVCircle.Color = TTNI_Configs.FOVColor
FOVCircle.Filled = false
FOVCircle.Visible = TTNI_Configs.FOVEnabled
FOVCircle.Radius = TTNI_Configs.FOVRadius

-- GET CLOSEST PLAYER FUNCTION
local function GetClosestPlayer()
    local target = nil
    local shortestDistance = math.huge

    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") and v.Character:FindFirstChild("Humanoid") and v.Character.Humanoid.Health > 0 then
            local pos, onScreen = Camera:WorldToViewportPoint(v.Character.HumanoidRootPart.Position)
            if onScreen then
                local mousePos = Vector2.new(Mouse.X, Mouse.Y)
                local distance = (Vector2.new(pos.X, pos.Y) - mousePos).Magnitude
                
                if distance < shortestDistance and distance <= (TTNI_Configs.FOVEnabled and TTNI_Configs.FOVRadius or math.huge) then
                    target = v
                    shortestDistance = distance
                end
            end
        end
    end
    return target
end

-- SIMPLE UI CREATION (TTNI PANEL)
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local Layout = Instance.new("UIListLayout")

ScreenGui.Name = "TTNI_Hub"
ScreenGui.Parent = game.CoreGui
ScreenGui.ResetOnSpawn = false

MainFrame.Name = "Main"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.Position = UDim2.new(0.05, 0, 0.4, 0)
MainFrame.Size = UDim2.new(0, 180, 0, 320)
MainFrame.Active = true
MainFrame.Draggable = true

Title.Parent = MainFrame
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
Title.Text = "TTNI HUB V1"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 18

Layout.Parent = MainFrame
Layout.Padding = UDim.new(0, 5)
Layout.SortOrder = Enum.SortOrder.LayoutOrder

-- Helper Function for Buttons
local function CreateButton(name, callback)
    local btn = Instance.new("TextButton")
    btn.Parent = MainFrame
    btn.Size = UDim2.new(1, -10, 0, 30)
    btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    btn.Text = name .. ": OFF"
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    
    local state = false
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.Text = name .. ": " .. (state and "ON" or "OFF")
        btn.BackgroundColor3 = state and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(60, 60, 60)
        callback(state)
    end)
end

-- ADDING FEATURES TO UI
CreateButton("Aim Assist", function(v) TTNI_Configs.AimAssist = v end)
CreateButton("Silent Aim", function(v) TTNI_Configs.SilentAim = v end)
CreateButton("Show FOV", function(v) TTNI_Configs.FOVEnabled = v end)
CreateButton("Chams", function(v) TTNI_Configs.Chams = v end)
CreateButton("ESP Boxes", function(v) TTNI_Configs.Boxes = v end)
CreateButton("Health Bar", function(v) TTNI_Configs.Health = v end)

-- MAIN LOOP (RENDER STEPPED)
RunService.RenderStepped:Connect(function()
    -- FOV Update
    FOVCircle.Visible = TTNI_Configs.FOVEnabled
    FOVCircle.Radius = TTNI_Configs.FOVRadius
    FOVCircle.Position = Vector2.new(Mouse.X, Mouse.Y + 36)

    local target = GetClosestPlayer()

    -- Aim Assist Logic
    if TTNI_Configs.AimAssist and target and target.Character then
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Character.HumanoidRootPart.Position)
    end

    -- Visuals Logic (Chams & ESP)
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            -- Chams
            local highlight = p.Character:FindFirstChild("TTNI_Highlight")
            if TTNI_Configs.Chams then
                if not highlight then
                    highlight = Instance.new("Highlight")
                    highlight.Name = "TTNI_Highlight"
                    highlight.Parent = p.Character
                end
                highlight.FillColor = Color3.fromRGB(255, 0, 0)
                highlight.Enabled = true
            elseif highlight then
                highlight.Enabled = false
            end
        end
    end
end)

-- SILENT AIM HOOK (Using MetaTable)
local mt = getrawmetatable(game)
local oldNamecall = mt.__namecall
setreadonly(mt, false)

mt.__namecall = newcclosure(function(self, ...)
    local args = {...}
    local method = getnamecallmethod()
    
    if TTNI_Configs.SilentAim and method == "FindPartOnRayWithIgnoreList" then
        local target = GetClosestPlayer()
        if target and target.Character then
            args[1] = Ray.new(Camera.CFrame.Position, (target.Character.HumanoidRootPart.Position - Camera.CFrame.Position).Unit * 1000)
            return oldNamecall(self, unpack(args))
        end
    end
    return oldNamecall(self, ...)
end)

setreadonly(mt, true)

-- Toggle Menu with Key
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == TTNI_Configs.MenuKey then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

print("TTNI HUB: Everything made by TTNI - Loaded!")
