-- [SCRIPT ORIGINAL COM TEAM CHECK ADICIONADO]
-- Team Check: Não mira em aliados (teamcheck = true por default)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- Configs
local FOV_RADIUS = 300
local MAX_DISTANCE = 400
local teamcheck = true  -- <--- TEAM CHECK ATIVADO (muda pra false se quiser mirar em aliados)

-- FOV Circle
local fov_circle = Drawing.new("Circle")
fov_circle.Visible = true
fov_circle.Radius = FOV_RADIUS
fov_circle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
fov_circle.Color = Color3.fromRGB(255, 0, 0)
fov_circle.Thickness = 3
fov_circle.Filled = false
fov_circle.Transparency = 0.8

-- ESP
local ESP_ENABLED = false
local ESP_Guis = {}

-- Função pra pegar Head do player (R6/R15 compatível)
local function getHead(player)
    if player.Character then
        return player.Character:FindFirstChild("Head") or 
               player.Character:FindFirstChild("UpperTorso") or 
               player.Character:FindFirstChild("Torso")
    end
    return nil
end

-- Wallcheck (raycast)
local function wallcheck(targetHead)
    local rayOrigin = Camera.CFrame.Position
    local rayDirection = (targetHead.Position - rayOrigin).Unit * 1000
    
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character, Camera}
    
    local raycastResult = workspace:Raycast(rayOrigin, rayDirection, raycastParams)
    return not raycastResult or raycastResult.Instance:IsDescendantOf(targetHead.Parent)
end

-- TEAM CHECK FUNCTION ⚠️ NOVA!
local function isValidTarget(player)
    if teamcheck then
        -- Não mira em si mesmo ou aliados
        if player == LocalPlayer then return false end
        if player.Team == LocalPlayer.Team then return false end
    end
    return true
end

-- Aimbot Loop
local function findTarget()
    local closestTarget = nil
    local shortestDistance = math.huge
    
    for _, player in pairs(Players:GetPlayers()) do
        if isValidTarget(player) and player.Character then  -- <--- TEAM CHECK AQUI!
            local head = getHead(player)
            if head and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
                
                local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
                local distance = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                
                if onScreen and distance < FOV_RADIUS and distance < shortestDistance and distance * 0.025 < MAX_DISTANCE then
                    if wallcheck(head) then
                        closestTarget = head
                        shortestDistance = distance
                    end
                end
            end
        end
    end
    
    return closestTarget
end

-- Main Aimbot
RunService.RenderStepped:Connect(function()
    local target = findTarget()
    
    if target then
        fov_circle.Color = Color3.fromRGB(0, 255, 0)  -- Verde = tem alvo válido
        local targetPos = target.Position
        local cameraPos = Camera.CFrame.Position
        local newCFrame = CFrame.lookAt(cameraPos, targetPos)
        Camera.CFrame = Camera.CFrame:Lerp(newCFrame, 0.15)
    else
        fov_circle.Color = Color3.fromRGB(255, 0, 0)  -- Vermelho = sem alvo
    end
    
    -- Update FOV position
    fov_circle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
end)

-- ESP Toggle
UserInputService = game:GetService("UserInputService")
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.RightBracket then
        ESP_ENABLED = not ESP_ENABLED
        if not ESP_ENABLED then
            for _, gui in pairs(ESP_Guis) do
                if gui then gui:Destroy() end
            end
            ESP_Guis = {}
        end
    end
end)

-- ESP Update
spawn(function()
    while true do
        if ESP_ENABLED then
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and isValidTarget(player) and player.Character then  -- <--- TEAM CHECK AQUI TAMBÉM!
                    local head = getHead(player)
                    if head and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.Health > 0 then
                        
                        local playerGui = ESP_Guis[player]
                        if not playerGui then
                            local billboard = Instance.new("BillboardGui")
                            billboard.Size = UDim2.new(0, 100, 0, 50)
                            billboard.StudsOffset = Vector3.new(0, 3, 0)
                            billboard.Parent = head
                            billboard.Adornee = head
                            billboard.AlwaysOnTop = true
                            
                            local label = Instance.new("TextLabel")
                            label.Size = UDim2.new(1, 0, 1, 0)
                            label.BackgroundTransparency = 1
                            label.TextColor3 = Color3.new(1, 1, 1)
                            label.TextStrokeTransparency = 0
                            label.TextScaled = true
                            label.Font = Enum.Font.GothamBold
                            label.Parent = billboard
                            
                            ESP_Guis[player] = billboard
                            playerGui = billboard
                        end
                        
                        local distance = math.floor((LocalPlayer.Character.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Magnitude)
                        playerGui.Frame.TextLabel.Text = player.Name .. "\n[" .. distance .. "m]"
                    end
                end
            end
        end
        wait(0.15)
    end
end)

print("✅ Aimbot + ESP + TEAM CHECK carregado!")
print("🔴 FOV: 300px | Distância: 400 studs")
print("⚡ ESP: ] (liga/desliga)")
print("👥 Team Check: ATIVADO (mude 'teamcheck = false' pra mirar aliados)")
