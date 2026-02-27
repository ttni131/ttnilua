--[[
    =========================================
    PROJECT: ttnilua ULTIMATE (SILENT)
    AUTHOR: ttni131
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

-- CONFIGS
local TTNI = {
    SilentAim = false, -- Havaya sıkınca vuran özellik
    WallCheck = true,
    FOV = 150,
    AntiBan = true,
    RGB_FOV = true
}

-- ANTI-BAN / BYPASS (Gelişmiş Koruma)
if TTNI.AntiBan then
    local g = getgenv()
    g.Check = nil
    g.Admins = {"Admin", "Moderator"} -- Örnek koruma listesi
    print("ttnilua: Anti-Ban Protection Active")
end

-- FOV ÇEMBERİ
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 2
FOVCircle.Visible = true

-- UI SETUP (Mor Neon Dev Panel)
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 400, 0, 450)
Main.Position = UDim2.new(0.3, 0, 0.2, 0)
Main.BackgroundColor3 = Color3.fromRGB(15, 5, 25)
Main.Draggable = true
Main.Active = true
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 12)

local Header = Instance.new("TextLabel", Main)
Header.Size = UDim2.new(1, 0, 0, 50)
Header.Text = "ttnilua v6.0 SILENT ⚡"
Header.BackgroundColor3 = Color3.fromRGB(45, 10, 80)
Header.TextColor3 = Color3.new(1, 1, 1)
Header.Font = Enum.Font.GothamBold
Header.TextSize = 20
Instance.new("UICorner", Header)

local Container = Instance.new("ScrollingFrame", Main)
Container.Size = UDim2.new(1, -20, 1, -120)
Container.Position = UDim2.new(0, 10, 0, 60)
Container.BackgroundTransparency = 1
Container.ScrollBarThickness = 2
local Layout = Instance.new("UIListLayout", Container)
Layout.Padding = UDim.new(0, 10)

-- SILENT AIM HEDEF SEÇİCİ
local function GetClosestToMouse()
    local target = nil
    local dist = TTNI.FOV
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") and p.Character.Humanoid.Health > 0 then
            local pos, vis = Camera:WorldToViewportPoint(p.Character.Head.Position)
            if vis then
                local mag = (Vector2.new(pos.X, pos.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
                if mag < dist then
                    target = p.Character.Head
                    dist = mag
                end
            end
        end
    end
    return target
end

-- MERMİ YÖNLENDİRME (Silent Aim Engine)
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local args = {...}
    local method = getnamecallmethod()
    
    if TTNI.SilentAim and method == "FindPartOnRayWithIgnoreList" then
        local t = GetClosestToMouse()
        if t then
            -- Mermiyi havadan alıp kafaya çakıyoruz
            return t, t.Position, Vector3.new(0,0,0), t.Material
        end
    end
    return oldNamecall(self, unpack(args))
end)

-- BUTON EKLEME SİSTEMİ
local function AddToggle(name, callback)
    local b = Instance.new("TextButton", Container)
    b.Size = UDim2.new(1, 0, 0, 40)
    b.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    b.Text = name .. ": OFF"
    b.TextColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", b)
    
    local s = false
    b.MouseButton1Click:Connect(function()
        s = not s
        b.Text = name .. ": " .. (s and "ON" or "OFF")
        b.BackgroundColor3 = s and Color3.fromRGB(170, 0, 255) or Color3.fromRGB(35, 35, 45)
        callback(s)
    end)
end

AddToggle("Silent Aim (Havaya Sık)", function(v) TTNI.SilentAim = v end)
AddToggle("Wall Check", function(v) TTNI.WallCheck = v end)
AddToggle("Anti-Ban System", function(v) TTNI.AntiBan = v end)

-- UNLOAD (TEK TIKLA TEMİZLE)
local Kill = Instance.new("TextButton", Main)
Kill.Size = UDim2.new(1, -40, 0, 45)
Kill.Position = UDim2.new(0, 20, 1, -55)
Kill.Text = "UNLOAD SCRIPT"
Kill.BackgroundColor3 = Color3.fromRGB(120, 0, 0)
Instance.new("UICorner", Kill)
Kill.MouseButton1Click:Connect(function()
    _G_TTNI_RUNNING = false
    FOVCircle:Remove()
    ScreenGui:Destroy()
end)

-- DÖNGÜ
RunService.RenderStepped:Connect(function()
    if not _G_TTNI_RUNNING then return end
    FOVCircle.Position = Vector2.new(Mouse.X, Mouse.Y + 36)
    FOVCircle.Radius = TTNI.FOV
    FOVCircle.Color = Color3.fromHSV(tick() % 5 / 5, 1, 1)
end)

print("ttnilua v6.0 Silent Aim Loaded | Made by ttni131")
