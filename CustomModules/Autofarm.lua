
--!strict

-- Autofarm - Walks to shop and iron when idle (VWRewrite Utility Module)

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local humanoid = nil
local rootPart = nil
local lastPosition = nil
local idleTimer = 0
local idleThreshold = 2
local shopToIronDelay = 5
local lockedShop = nil
local movingToIron = false
local delayTimer = 0

local GoToShopToggle
local GoToIronToggle

local function isShop(part)
    return part:IsA("BasePart") and part.Name:match("^%d+_item_shop") ~= nil
end

local function getNearestShop()
    local closestShop = nil
    local shortestDistance = math.huge

    for _, obj in ipairs(workspace:GetDescendants()) do
        if isShop(obj) then
            local distance = (obj.Position - rootPart.Position).Magnitude
            if distance < shortestDistance then
                closestShop = obj
                shortestDistance = distance
            end
        end
    end

    return closestShop
end

local function getNearestIronBlock()
    local closest = nil
    local shortestDistance = math.huge

    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name == "iron_block" then
            local distance = (obj.Position - rootPart.Position).Magnitude
            if distance < shortestDistance then
                closest = obj
                shortestDistance = distance
            end
        end
    end

    return closest
end

local function setupCharacter(character)
    humanoid = character:WaitForChild("Humanoid", 5)
    rootPart = character:WaitForChild("HumanoidRootPart", 5)
    lastPosition = rootPart and rootPart.Position or Vector3.zero
    idleTimer = 0
    delayTimer = 0
    lockedShop = nil
    movingToIron = false
end

local Autofarm = vape.Categories.Utility:CreateModule({
    Name = "Autofarm",
    Tooltip = "Walks to shop and iron when idle",
    Function = function(callback)
        if callback then
            if LocalPlayer.Character then
                setupCharacter(LocalPlayer.Character)
            end

            Autofarm:Clean(LocalPlayer.CharacterAdded:Connect(function(char)
                char:WaitForChild("HumanoidRootPart", 5)
                setupCharacter(char)
            end))

            Autofarm:Clean(RunService.RenderStepped:Connect(function(dt)
                if not (humanoid and rootPart) then return end

                local movedDistance = (rootPart.Position - lastPosition).Magnitude

                if movedDistance < 0.1 then
                    idleTimer += dt
                else
                    idleTimer = 0
                    delayTimer = 0
                    lockedShop = nil
                    movingToIron = false
                end

                lastPosition = rootPart.Position

                if idleTimer >= idleThreshold then
                    if not lockedShop and not movingToIron and GoToShopToggle.Enabled then
                        lockedShop = getNearestShop()
                        if lockedShop then
                            humanoid:MoveTo(lockedShop.Position)
                            idleTimer = 0
                        end
                    elseif lockedShop and not movingToIron and GoToIronToggle.Enabled then
                        delayTimer += dt
                        if delayTimer >= shopToIronDelay then
                            local ironBlock = getNearestIronBlock()
                            if ironBlock then
                                humanoid:MoveTo(ironBlock.Position)
                                movingToIron = true
                            end
                        end
                    end
                end
            end)))
        else
            humanoid = nil
            rootPart = nil
        end
    end
})

GoToShopToggle = Autofarm:CreateToggle({
    Name = "Go To Shop",
    Default = true
})

GoToIronToggle = Autofarm:CreateToggle({
    Name = "Go To Iron After Shop",
    Default = true
})

return Autofarm
