--[[
    =========================================
    PROJECT: TTNI OFFICIAL HUB (WINTER EDITION)
    AUTHOR: ttni131
    VERSION: 2.0 (Self-Destruct Added)
    Everything made by ttni131.
    =========================================
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- SCRIPT DURUMU (Durdurmak için kontrol)
local _G_TTNI_RUNNING = true

-- CONFIGS
local TTNI_Configs = {
    AimAssist = false,
    FOVEnabled = true,
    FOVRadius = 150,
    Chams = false,
    MenuKey = Enum.KeyCode.RightShift
}

-- FOV ÇEMBERİ
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 2
FOVCircle.Color = Color3.fromRGB(180, 240, 255)
FOVCircle.Filled = false
FOVCircle.Transparency = 0.8
FOVCircle.Visible = TTNI_Configs.FOVEnabled
FOVCircle.Radius = TTNI_Configs.FOVRadius
FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

-- UI OLUŞTURMA
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "TTNI_Official_Winter"

local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 230, 0, 350) -- Biraz uzattık buton sığsın diye
Main.Position = UDim2.new(0.05, 0, 0.4, 0)
Main.BackgroundColor3 = Color3.fromRGB(10, 20, 30)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true

local UICorner = Instance.new("UICorner", Main)
UICorner.CornerRadius = UDim.new(0, 15)

local Header = Instance.new("Frame", Main)
Header.Size = UDim2.new(1, 0, 0, 50)
Header.BackgroundColor3 = Color3.fromRGB(200, 230, 255)
Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 15)

local Title = Instance.new("TextLabel", Header)
Title.Size = UDim2.new(1, 0, 1, 0)
Title.Text = "TTNI OFFICIAL ❄️"
Title.TextColor3 = Color3.fromRGB(10, 40, 70)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.BackgroundTransparency = 1

local Container = Instance.new("ScrollingFrame", Main)
Container.Size = UDim2.new(1, -20, 1, -110)
Container.Position = UDim2.new(0, 10, 0, 60)
Container.BackgroundTransparency = 1
Container.ScrollBarThickness = 0
Container.CanvasSize = UDim2.new(0, 0, 1.2, 0)

local Layout = Instance.new("UIListLayout", Container)
Layout.Padding = UDim.new(0, 8)
Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- BUTON FONKSİYONU
local function CreateTog(name, callback)
    local Button = Instance.new("TextButton", Container)
    Button.Size = UDim2.new(0, 190, 0, 40)
    Button.BackgroundColor3 = Color3.fromRGB(25, 45, 65)
    Button.Text = "  " .. name
    Button.TextColor3 = Color3.fromRGB(200, 230, 255)
    Button.Font = Enum.Font.GothamMedium
    Button.TextSize = 13
    Button.TextXAlignment = Enum.TextXAlignment.Left
    Instance.new("UICorner", Button).CornerRadius = UDim.new(0, 8)

    local StatusInd = Instance.new("Frame", Button)
    StatusInd.Size = UDim2.new(0, 8, 0, 8)
    StatusInd.Position = UDim2.new(1, -25, 0.5, -4)
    StatusInd.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    Instance.new("UICorner", StatusInd).CornerRadius = UDim.new(1, 0)

    local enabled = false
    Button.MouseButton1Click:Connect(function()
        if not _G_TTNI_RUNNING then return end
        enabled = not enabled
        callback(enabled)
        StatusInd.BackgroundColor3 = enabled and Color3.fromRGB(0, 255, 150) or Color3.fromRGB(255, 50, 50)
    end)
end

-- ÖZELLİKLER
CreateTog("Flick Aim Assist", function(v) TTNI_Configs.AimAssist = v end)
CreateTog("Show Frost FOV", function(v) TTNI_Configs.FOVEnabled = v end)
CreateTog("Winter Chams", function(v) TTNI_Configs.Chams = v end)

-- KILL SCRIPT BUTTON (Alt+F4 Yerine)
local KillBtn = Instance.new("TextButton", Container)
KillBtn.Size = UDim2.new(0, 190, 0, 40)
KillBtn.BackgroundColor3 = Color3.fromRGB(80, 20, 20)
KillBtn.Text = "UNLOAD SCRIPT (EXIT)"
KillBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
KillBtn.Font = Enum.Font.GothamBold
Instance.new("UICorner", KillBtn).CornerRadius = UDim.new(0, 8)

KillBtn.MouseButton1Click:Connect(function()
    _G_TTNI_RUNNING = false
    FOVCircle:Remove()
    ScreenGui:Destroy()
    -- Chams Temizle
    for _, p in pairs(Players:GetPlayers()) do
        if p.Character and p.Character:FindFirstChild("TTNI_Ice") then
            p.Character.TTNI_Ice:Destroy()
        end
    end
    print("TTNI HUB: Unloaded Successfully.")
end)

-- ENGINE
RunService.RenderStepped:Connect(function()
    if not _G_TTNI_RUNNING then return end
    
    FOVCircle.Visible = TTNI_Configs.FOVEnabled
    FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    
    if TTNI_Configs.AimAssist then
        local t = nil
        local sd = math.huge
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character.Humanoid.Health > 0 then
                local pos, vis = Camera:WorldToViewportPoint(p.Character.HumanoidRootPart.Position)
                if vis then
                    local d = (Vector2.new(pos.X, pos.Y) - FOVCircle.Position).Magnitude
                    if d < sd and d <= TTNI_Configs.FOVRadius then
                        t = p; sd = d
                    end
                end
            end
        end
        if t then Camera.CFrame = CFrame.new(Camera.CFrame.Position, t.Character.HumanoidRootPart.Position) end
    end

    if TTNI_Configs.Chams then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and not p.Character:FindFirstChild("TTNI_Ice") then
                local h = Instance.new("Highlight", p.Character)
                h.Name = "TTNI_Ice"
                h.FillColor = Color3.fromRGB(150, 230, 255)
            end
        end
    end
end)

UserInputService.InputBegan:Connect(function(k)
    if k.KeyCode == TTNI_Configs.MenuKey and _G_TTNI_RUNNING then Main.Visible = not Main.Visible end
end)
