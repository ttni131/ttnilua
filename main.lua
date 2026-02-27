--[[
    =========================================
    PROJECT: ttnilua ULTIMATE VIP (FIXED)
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

-- AYARLAR
local TTNI_Configs = {
    AimAssist = false,
    WallCheck = false, -- Eğer kitlenmezse bunu OFF yaparsın
    FOVRadius = 150,
    ESP_Enabled = false,
    KillSound = true,
    MenuKey = Enum.KeyCode.RightShift
}

-- RGB FOV ÇEMBERİ
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 2.5
FOVCircle.Visible = true
FOVCircle.Radius = TTNI_Configs.FOVRadius
FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

-- UI (DAHA BÜYÜK VE MOR)
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 320, 0, 500) -- Daha büyük panel
Main.Position = UDim2.new(0.05, 0, 0.2, 0)
Main.BackgroundColor3 = Color3.fromRGB(20, 0, 40)
Main.Active = true
Main.Draggable = true
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 15)

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, 0, 0, 60)
Title.Text = "ttnilua VIP v3.0 ⚡"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.BackgroundColor3 = Color3.fromRGB(40, 0, 80)
Title.TextSize = 22
Title.Font = Enum.Font.GothamBold
Instance.new("UICorner", Title).CornerRadius = UDim.new(0, 15)

local Container = Instance.new("ScrollingFrame", Main)
Container.Size = UDim2.new(1, -20, 1, -150)
Container.Position = UDim2.new(0, 10, 0, 75)
Container.BackgroundTransparency = 1
Container.ScrollBarThickness = 2
local Layout = Instance.new("UIListLayout", Container)
Layout.Padding = UDim.new(0, 10)

-- SES FONKSİYONU
local function PlayDeathSound()
    local s = Instance.new("Sound", game.Workspace)
    s.SoundId = "rbxassetid://4813331199"
    s.Volume = 5
    s:Play()
    task.wait(1)
    s:Destroy()
end

-- TARGET SİSTEMİ (FIXED)
local function GetClosestTarget()
    local target = nil
    local dist = TTNI_Configs.FOVRadius
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local hum = p.Character:FindFirstChild("Humanoid")
            if hum and hum.Health > 0 then
                local pos, vis = Camera:WorldToViewportPoint(p.Character.HumanoidRootPart.Position)
                if vis then
                    local mag = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                    if mag < dist then
                        -- Duvar Kontrolü (Opsiyonel)
                        if TTNI_Configs.WallCheck then
                            local ray = Camera:ViewportPointToRay(pos.X, pos.Y)
                            local hit = workspace:FindPartOnRay(ray, LocalPlayer.Character)
                            if hit and hit:IsDescendantOf(p.Character) then
                                target = p.Character.HumanoidRootPart
                                dist = mag
                            end
                        else
                            target = p.Character.HumanoidRootPart
                            dist = mag
                        end
                    end
                end
            end
        end
    end
    return target
end

-- BUTON EKLEME
local function CreateBtn(text, callback)
    local b = Instance.new("TextButton", Container)
    b.Size = UDim2.new(1, 0, 0, 45)
    b.BackgroundColor3 = Color3.fromRGB(60, 0, 120)
    b.Text = text
    b.TextColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", b)
    
    local val = false
    b.MouseButton1Click:Connect(function()
        val = not val
        callback(val)
        b.BackgroundColor3 = val and Color3.fromRGB(170, 0, 255) or Color3.fromRGB(60, 0, 120)
    end)
end

CreateBtn("Aimbot (Fixed Lock)", function(v) TTNI_Configs.AimAssist = v end)
CreateBtn("Wall Check (Legit)", function(v) TTNI_Configs.WallCheck = v end)
CreateBtn("VIP ESP (Highlight)", function(v) TTNI_Configs.ESP_Enabled = v end)
CreateBtn("Kill Sound (VIP)", function(v) TTNI_Configs.KillSound = v end)

-- FOV SLIDER (MANUEL)
local Slider = Instance.new("TextButton", Container)
Slider.Size = UDim2.new(1, 0, 0, 45)
Slider.Text = "FOV: " .. TTNI_Configs.FOVRadius .. " (Click to +)"
Slider.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Instance.new("UICorner", Slider)
Slider.MouseButton1Click:Connect(function()
    TTNI_Configs.FOVRadius = TTNI_Configs.FOVRadius + 50
    if TTNI_Configs.FOVRadius > 500 then TTNI_Configs.FOVRadius = 50 end
    Slider.Text = "FOV: " .. TTNI_Configs.FOVRadius .. " (Click to +)"
    FOVCircle.Radius = TTNI_Configs.FOVRadius
end)

-- UNLOAD
local Kill = Instance.new("TextButton", Main)
Kill.Size = UDim2.new(1, -40, 0, 45)
Kill.Position = UDim2.new(0, 20, 1, -60)
Kill.Text = "UNLOAD TTNI"
Kill.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
Instance.new("UICorner", Kill)
Kill.MouseButton1Click:Connect(function()
    _G_TTNI_RUNNING = false
    FOVCircle:Remove()
    ScreenGui:Destroy()
end)

-- LOOP
RunService.RenderStepped:Connect(function()
    if not _G_TTNI_RUNNING then return end
    
    -- RGB FOV
    FOVCircle.Color = Color3.fromHSV(tick() % 5 / 5, 1, 1)
    FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    
    -- AIMBOT LOCK
    if TTNI_Configs.AimAssist then
        local t = GetClosestTarget()
        if t then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, t.Position)
        end
    end

    -- ESP & KILL SOUNDS
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local h = p.Character:FindFirstChild("TTNI_ESP")
            if TTNI_Configs.ESP_Enabled and p.Character:FindFirstChild("Humanoid") and p.Character.Humanoid.Health > 0 then
                if not h then
                    h = Instance.new("Highlight", p.Character)
                    h.Name = "TTNI_ESP"
                    h.FillColor = Color3.fromRGB(170, 0, 255)
                    h.OutlineColor = Color3.new(1,1,1)
                end
            elseif h then h:Destroy() end
        end
    end
end)

-- ÖLÜM TAKİBİ
Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function(c)
        c:WaitForChild("Humanoid").Died:Connect(function()
            if TTNI_Configs.KillSound then PlayDeathSound() end
        end)
    end)
end)

print("ttnilua VIP Fixed - Everything made by ttni131")
