-- [[ SAMEH HUB VIP - V2.6 FULL RESTORED & DEATH FIX ]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local Options = {
    Aimbot = false, 
    AimLock = false, 
    WallCheck = true, 
    TeamCheck = false, 
    TargetPart = "Head", 
    AimKey = Enum.KeyCode.C,
    ESP_Master = false, ESP_Boxes = false, ESP_Names = false, ESP_Tracers = false,
    WalkSpeed = 16, JumpPower = 50, 
    FlyEnabled = false, FlySpeed = 50,
    MenuKey = Enum.KeyCode.LeftControl
}

local LockedTarget = nil 
local IsLocking = false 

-- [[ وظيفة التحقق المحدثة: تمنع ملاحقة الموتى واللاعبين في الرسبون ]]
local function IsValid(p)
    if p and p.Character and p.Character:FindFirstChild(Options.TargetPart) and p.Character:FindFirstChild("Humanoid") then
        local humanoid = p.Character.Humanoid
        local rootPart = p.Character:FindFirstChild("HumanoidRootPart")
        
        -- التحقق: 1.الصحة أكبر من صفر / 2.الجسم لم ينزل تحت الخريطة (الرسبون)
        if humanoid.Health > 0 and rootPart and rootPart.Position.Y > -400 then 
            return true
        end
    end
    return false
end

local function IsVisible(targetPart)
    if not Options.WallCheck then return true end
    local character = LocalPlayer.Character
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {character, targetPart.Parent}
    local direction = (targetPart.Position - Camera.CFrame.Position)
    local result = workspace:Raycast(Camera.CFrame.Position, direction, params)
    return result == nil
end

-- [[ محرك الايمبوت المصلح ]]
RunService.RenderStepped:Connect(function()
    if Options.Aimbot then
        if Options.AimLock then
            if IsLocking and IsValid(LockedTarget) then
                Camera.CFrame = CFrame.new(Camera.CFrame.Position, LockedTarget.Character[Options.TargetPart].Position)
            else
                IsLocking = false
                LockedTarget = nil
            end
        else
            if UserInputService:IsKeyDown(Options.AimKey) then
                if IsValid(LockedTarget) then
                    Camera.CFrame = CFrame.new(Camera.CFrame.Position, LockedTarget.Character[Options.TargetPart].Position)
                else
                    local target, dist = nil, math.huge
                    for _, p in pairs(Players:GetPlayers()) do
                        if p ~= LocalPlayer and IsValid(p) then
                            if Options.TeamCheck and p.Team == LocalPlayer.Team then continue end
                            local part = p.Character[Options.TargetPart]
                            if IsVisible(part) then
                                local pos, on = Camera:WorldToViewportPoint(part.Position)
                                if on then
                                    local mag = (Vector2.new(pos.X, pos.Y) - UserInputService:GetMouseLocation()).Magnitude
                                    if mag < dist then dist = mag; target = p end
                                end
                            end
                        end
                    end
                    LockedTarget = target
                end
            else
                LockedTarget = nil
            end
        end
    end
end)

UserInputService.InputBegan:Connect(function(i, g)
    if not g and i.KeyCode == Options.AimKey and Options.Aimbot and Options.AimLock then
        if IsLocking then IsLocking = false; LockedTarget = nil
        else
            local target, dist = nil, math.huge
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and IsValid(p) then
                    if Options.TeamCheck and p.Team == LocalPlayer.Team then continue end
                    local part = p.Character[Options.TargetPart]
                    if IsVisible(part) then
                        local pos, on = Camera:WorldToViewportPoint(part.Position)
                        if on then
                            local mag = (Vector2.new(pos.X, pos.Y) - UserInputService:GetMouseLocation()).Magnitude
                            if mag < dist then dist = mag; target = p end
                        end
                    end
                end
            end
            if target then LockedTarget = target; IsLocking = true end
        end
    end
end)

-- [[ محرك الطيران ]]
local BodyGyro, BodyVelocity
RunService.RenderStepped:Connect(function()
    if Options.FlyEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local Root = LocalPlayer.Character.HumanoidRootPart
        if not Root:FindFirstChild("FlyGyro") then
            BodyGyro = Instance.new("BodyGyro", Root); BodyGyro.Name = "FlyGyro"
            BodyGyro.P = 9e4; BodyGyro.maxTorque = Vector3.new(9e9, 9e9, 9e9)
            BodyVelocity = Instance.new("BodyVelocity", Root); BodyVelocity.Name = "FlyVel"
            BodyVelocity.maxForce = Vector3.new(9e9, 9e9, 9e9)
            LocalPlayer.Character.Humanoid.PlatformStand = true
        end
        BodyGyro.cframe = Camera.CFrame
        local Dir = Vector3.new(0,0,0)
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then Dir = Dir + Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then Dir = Dir - Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then Dir = Dir + Camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then Dir = Dir - Camera.CFrame.RightVector end
        BodyVelocity.velocity = Dir * Options.FlySpeed
    else
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            if LocalPlayer.Character.HumanoidRootPart:FindFirstChild("FlyGyro") then LocalPlayer.Character.HumanoidRootPart.FlyGyro:Destroy() end
            if LocalPlayer.Character.HumanoidRootPart:FindFirstChild("FlyVel") then LocalPlayer.Character.HumanoidRootPart.FlyVel:Destroy() end
            if LocalPlayer.Character:FindFirstChild("Humanoid") then LocalPlayer.Character.Humanoid.PlatformStand = false end
        end
    end
end)

-- [[ محرك الشخصية و ESP ]]
RunService.Stepped:Connect(function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = Options.WalkSpeed
        LocalPlayer.Character.Humanoid.JumpPower = Options.JumpPower
    end
end)

local function CreateESP(p)
    local Box = Drawing.new("Square"); Box.Thickness = 1; Box.Color = Color3.fromRGB(80, 0, 255)
    local Name = Drawing.new("Text"); Name.Size = 14; Name.Center = true; Name.Outline = true; Name.Color = Color3.new(1,1,1)
    local Tracer = Drawing.new("Line"); Tracer.Color = Color3.fromRGB(80, 0, 255)
    RunService.RenderStepped:Connect(function()
        if Options.ESP_Master and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character.Humanoid.Health > 0 then
            if Options.TeamCheck and p.Team == LocalPlayer.Team then
                Box.Visible = false; Name.Visible = false; Tracer.Visible = false
            else
                local pos, onscreen = Camera:WorldToViewportPoint(p.Character.HumanoidRootPart.Position)
                if onscreen then
                    local size = Vector2.new(2000/pos.Z, 2500/pos.Z)
                    Box.Visible = Options.ESP_Boxes; Box.Size = size; Box.Position = Vector2.new(pos.X - size.X/2, pos.Y - size.Y/2)
                    Name.Visible = Options.ESP_Names; Name.Text = p.Name; Name.Position = Vector2.new(pos.X, pos.Y - size.Y/2 - 15)
                    Tracer.Visible = Options.ESP_Tracers; Tracer.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y); Tracer.To = Vector2.new(pos.X, pos.Y)
                else Box.Visible = false; Name.Visible = false; Tracer.Visible = false end
            end
        else Box.Visible = false; Name.Visible = false; Tracer.Visible = false end
    end)
end
for _, v in pairs(Players:GetPlayers()) do if v ~= LocalPlayer then CreateESP(v) end end
Players.PlayerAdded:Connect(CreateESP)

-- [[ الواجهة الرسومية الكاملة ]]
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 600, 0, 420); Main.Position = UDim2.new(0.5, -300, 0.5, -210)
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15); Main.BorderSizePixel = 0
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 12)
Instance.new("UIStroke", Main).Color = Color3.fromRGB(80, 0, 255)

local Sidebar = Instance.new("Frame", Main)
Sidebar.Size = UDim2.new(0, 160, 1, 0); Sidebar.BackgroundColor3 = Color3.fromRGB(10, 10, 10); Instance.new("UICorner", Sidebar)
local Logo = Instance.new("TextLabel", Sidebar); Logo.Size = UDim2.new(1, 0, 0, 60); Logo.Text = "SAMEH VIP"; Logo.TextColor3 = Color3.fromRGB(80, 0, 255); Logo.Font = "GothamBold"; Logo.TextSize = 22; Logo.BackgroundTransparency = 1

local Pages = Instance.new("Frame", Main); Pages.Size = UDim2.new(1, -170, 1, -20); Pages.Position = UDim2.new(0, 165, 0, 10); Pages.BackgroundTransparency = 1

local function CreateTab(name, order)
    local Page = Instance.new("ScrollingFrame", Pages); Page.Size = UDim2.new(1, 0, 1, 0); Page.Visible = (order == 1); Page.BackgroundTransparency = 1; Page.ScrollBarThickness = 0
    Instance.new("UIListLayout", Page).Padding = UDim.new(0, 8)
    local TabBtn = Instance.new("TextButton", Sidebar); TabBtn.Size = UDim2.new(0.9, 0, 0, 40); TabBtn.Position = UDim2.new(0.05, 0, 0, 70 + (order-1)*45)
    TabBtn.Text = name; TabBtn.BackgroundColor3 = (order == 1 and Color3.fromRGB(80, 0, 255) or Color3.fromRGB(25, 25, 25)); TabBtn.TextColor3 = Color3.new(1,1,1); TabBtn.Font = "GothamBold"; Instance.new("UICorner", TabBtn)
    TabBtn.MouseButton1Click:Connect(function()
        for _, p in pairs(Pages:GetChildren()) do if p:IsA("ScrollingFrame") then p.Visible = false end end
        for _, b in pairs(Sidebar:GetChildren()) do if b:IsA("TextButton") then b.BackgroundColor3 = Color3.fromRGB(25, 25, 25) end end
        Page.Visible = true; TabBtn.BackgroundColor3 = Color3.fromRGB(80, 0, 255)
    end)
    return Page
end

local function AddToggle(parent, text, key)
    local Btn = Instance.new("TextButton", parent); Btn.Size = UDim2.new(0.95, 0, 0, 45); Btn.BackgroundColor3 = Options[key] and Color3.fromRGB(80, 0, 255) or Color3.fromRGB(30, 30, 30)
    Btn.Text = text .. ": " .. (Options[key] and "ON" or "OFF"); Btn.TextColor3 = Color3.new(1,1,1); Btn.Font = "GothamSemibold"; Instance.new("UICorner", Btn)
    Btn.MouseButton1Click:Connect(function()
        Options[key] = not Options[key]; Btn.Text = text .. ": " .. (Options[key] and "ON" or "OFF"); Btn.BackgroundColor3 = Options[key] and Color3.fromRGB(80, 0, 255) or Color3.fromRGB(30, 30, 30)
    end)
end

local function AddSlider(parent, text, min, max, key)
    local Frame = Instance.new("Frame", parent); Frame.Size = UDim2.new(0.95, 0, 0, 60); Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25); Instance.new("UICorner", Frame)
    local Label = Instance.new("TextLabel", Frame); Label.Size = UDim2.new(1, -20, 0, 25); Label.Position = UDim2.new(0, 10, 0, 5); Label.Text = text .. ": " .. Options[key]; Label.TextColor3 = Color3.new(1,1,1); Label.BackgroundTransparency = 1; Label.Font = "GothamSemibold"; Label.TextXAlignment = "Left"
    local SliderBg = Instance.new("Frame", Frame); SliderBg.Size = UDim2.new(0.9, 0, 0, 4); SliderBg.Position = UDim2.new(0.05, 0, 0, 40); SliderBg.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    local SliderFill = Instance.new("Frame", SliderBg); SliderFill.Size = UDim2.new((Options[key]-min)/(max-min), 0, 1, 0); SliderFill.BackgroundColor3 = Color3.fromRGB(80, 0, 255)
    local dragging = false
    Frame.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end end)
    UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
    UserInputService.InputChanged:Connect(function(i) if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then 
        local p = math.clamp((i.Position.X - SliderBg.AbsolutePosition.X) / SliderBg.AbsoluteSize.X, 0, 1)
        SliderFill.Size = UDim2.new(p, 0, 1, 0); Options[key] = math.floor(min + (max-min)*p); Label.Text = text .. ": " .. Options[key]
    end end)
end

local function AddDropdown(p, t, list, key)
    local Btn = Instance.new("TextButton", p); Btn.Size = UDim2.new(0.95, 0, 0, 45); Btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35); Btn.Text = t .. ": " .. Options[key]; Btn.TextColor3 = Color3.new(1,1,1); Btn.Font = "GothamSemibold"; Instance.new("UICorner", Btn)
    local i = 1; Btn.MouseButton1Click:Connect(function() i = i + 1; if i > #list then i = 1 end; Options[key] = list[i]; Btn.Text = t .. ": " .. list[i] end)
end

local function AddKeybind(p, t, key)
    local Btn = Instance.new("TextButton", p); Btn.Size = UDim2.new(0.95, 0, 0, 45); Btn.BackgroundColor3 = Color3.fromRGB(35, 35, 35); Btn.Text = t .. ": " .. Options[key].Name; Btn.TextColor3 = Color3.new(1,1,1); Btn.Font = "GothamSemibold"; Instance.new("UICorner", Btn)
    Btn.MouseButton1Click:Connect(function() Btn.Text = "..."; local c; c = UserInputService.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.Keyboard then Options[key] = i.KeyCode; Btn.Text = t .. ": " .. i.KeyCode.Name; c:Disconnect() end end) end)
end

local AimPage = CreateTab("Aimbot", 1)
local VisPage = CreateTab("Visuals", 2)
local PlayerPage = CreateTab("Player", 3)
local SetPage = CreateTab("Settings", 4)

AddToggle(AimPage, "Enable Aimbot", "Aimbot")
AddDropdown(AimPage, "Aim Part", {"Head", "UpperTorso", "HumanoidRootPart"}, "TargetPart")
AddToggle(AimPage, "Wall Check", "WallCheck")
AddToggle(AimPage, "Team Check", "TeamCheck")

AddToggle(VisPage, "Enable ESP System", "ESP_Master")
AddToggle(VisPage, "Show Boxes", "ESP_Boxes")
AddToggle(VisPage, "Show Names", "ESP_Names")
AddToggle(VisPage, "Show Tracers", "ESP_Tracers")

AddSlider(PlayerPage, "Walk Speed", 16, 250, "WalkSpeed")
AddSlider(PlayerPage, "Jump Power", 50, 500, "JumpPower")
AddToggle(PlayerPage, "Enable Fly", "FlyEnabled")
AddSlider(PlayerPage, "Fly Speed", 10, 500, "FlySpeed")

AddToggle(SetPage, "Aim Lock (Toggle)", "AimLock")
AddKeybind(SetPage, "Aimbot Key", "AimKey")
AddKeybind(SetPage, "Menu Key", "MenuKey")

UserInputService.InputBegan:Connect(function(i, g) if not g and i.KeyCode == Options.MenuKey then Main.Visible = not Main.Visible end end)
