-- v12 WALLCHECK FIX + FOV + AIMBOT SEMPRE ATIVO
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Cam = workspace.CurrentCamera
local LP = Players.LocalPlayer

local ESPOn = true
local AimOn = true
local ESPGuis = {}

-- FOV CIRCLE
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = game.CoreGui
ScreenGui.Name = "FOVCircle"

local FOVCircle = Drawing.new("Circle")
FOVCircle.Visible = true
FOVCircle.Color = Color3.new(1, 0, 0)
FOVCircle.Thickness = 3
FOVCircle.NumSides = 100
FOVCircle.Radius = 300
FOVCircle.Filled = false
FOVCircle.Transparency = 0.7

print("🚀 v12 WALLCHECK FIX carregado!")

local function getRoot(char)
    return char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")
end

-- WALLCHECK PERFEITO (raycast camera -> head)
local function canSee(head, targetChar)
    local origin = Cam.CFrame.Position
    local direction = head.Position - origin
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    raycastParams.FilterDescendantsInstances = {LP.Character, Cam}
    
    local raycastResult = workspace:Raycast(origin, direction, raycastParams)
    
    if raycastResult then
        -- Se acertou o próprio target OU nada no meio
        return raycastResult.Instance:IsDescendantOf(targetChar)
    end
    
    return true  -- Linha de visão limpa
end

local function addESP(plr)
    if plr == LP then return end
    
    local function onChar(char)
        wait(0.3)
        local root = getRoot(char)
        if not root then return end
        
        local old = root:FindFirstChild("ESPv12")
        if old then old:Destroy() end
        
        local bg = Instance.new("BillboardGui")
        bg.Name = "ESPv12"
        bg.Adornee = root
        bg.Parent = root
        bg.Size = UDim2.new(0, 180, 0, 50)
        bg.StudsOffset = Vector3.new(0, 4, 0)
        bg.AlwaysOnTop = true
        
        local txt = Instance.new("TextLabel")
        txt.Parent = bg
        txt.Size = UDim2.new(1, 0, 1, 0)
        txt.BackgroundTransparency = 1
        txt.Text = plr.Name .. " [0m]"
        txt.TextColor3 = Color3.new(1, 1, 1)
        txt.TextStrokeTransparency = 0
        txt.TextStrokeColor3 = Color3.new(0, 0, 0)
        txt.TextScaled = true
        txt.Font = Enum.Font.SourceSansBold
        
        ESPGuis[plr] = txt
    end
    
    if plr.Character then onChar(plr.Character) end
    plr.CharacterAdded:Connect(onChar)
end

for _, p in Players:GetPlayers() do addESP(p) end
Players.PlayerAdded:Connect(addESP)

-- UPDATE DISTÂNCIA
spawn(function()
    while true do
        if ESPOn then
            local myRoot = getRoot(LP.Character)
            if myRoot then
                for plr, txt in pairs(ESPGuis) do
                    if plr.Character and txt.Parent then
                        local targetRoot = getRoot(plr.Character)
                        if targetRoot then
                            local dist = (myRoot.Position - targetRoot.Position).Magnitude
                            txt.Text = plr.Name .. " [" .. math.floor(dist) .. "m]"
                        end
                    end
                end
            end
        end
        wait(0.15)
    end
end)

-- Toggle ESP só
UIS.InputBegan:Connect(function(inp)
    if inp.KeyCode == Enum.KeyCode.RightBracket then
        ESPOn = not ESPOn
        print("ESP: " .. (ESPOOn and "ON" or "OFF"))
    end
end)

-- LOOP PRINCIPAL: FOV + WALLCHECK + AIMBOT
RunService.RenderStepped:Connect(function()
    local center = Vector2.new(Cam.ViewportSize.X/2, Cam.ViewportSize.Y/2)
    FOVCircle.Position = center
    
    if not AimOn then return end
    
    local myChar = LP.Character
    if not myChar then return end
    local myRoot = getRoot(myChar)
    if not myRoot then return end
    
    local closestHead = nil
    local closestDist = math.huge
    
    for _, plr in Players:GetPlayers() do
        if plr ~= LP and plr.Character then
            local head = plr.Character:FindFirstChild("Head")
            local hum = plr.Character:FindFirstChild("Humanoid")
            if head and hum and hum.Health > 0 then
                
                -- FOV CHECK
                local screenPos, onScreen = Cam:WorldToViewportPoint(head.Position)
                local inFOV = onScreen and (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude <= FOVCircle.Radius
                
                -- WALLCHECK
                local visible = canSee(head, plr.Character)
                
                local dist = (myRoot.Position - head.Position).Magnitude
                if dist < closestDist and dist < 400 and inFOV and visible then
                    closestDist = dist
                    closestHead = head
                end
            end
        end
    end
    
    if closestHead then
        -- FOV VERDE + MIRA
        FOVCircle.Color = Color3.new(0, 1, 0)
        local targetCFrame = CFrame.lookAt(Cam.CFrame.Position, closestHead.Position)
        Cam.CFrame = Cam.CFrame:Lerp(targetCFrame, 0.15)
    else
        FOVCircle.Color = Color3.new(1, 0, 0)  -- Vermelho sem alvo
    end
end)

print("🎯 FOV VERDE = MIRANDO (WALLCHECK OK) | VERMELHO = BLOQUEADO!")
print("Aimbot SEMPRE ATIVO c/ WALLCHECK!")
