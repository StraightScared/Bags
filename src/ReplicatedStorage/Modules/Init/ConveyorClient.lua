local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Models = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Models")
local BagModel = Models:WaitForChild("Bag")
local RunService = game:GetService("RunService")
local Map = workspace:WaitForChild("Map")
local Conveyors = Map:WaitForChild("Conveyors")
local Packet = require(ReplicatedStorage.Modules.Packet)
local TweenService = game:GetService("TweenService")
local BagSpawned = Packet("BagSpawned", Packet.NumberU8, Packet.NumberU16, Packet.NumberU8, Packet.NumberU8, Packet.NumberU8, Packet.EnumItem)
local BagDeleted = Packet("BagDeleted", Packet.NumberU8, Packet.NumberU16)
local BagClicked = Packet("BagClicked", Packet.NumberU8, Packet.NumberU16)

local RaycastParam = RaycastParams.new()
RaycastParam.FilterType = Enum.RaycastFilterType.Include
RaycastParam.FilterDescendantsInstances = {Map}
local ConveyorClient = {}
ConveyorClient.__index = ConveyorClient

function ConveyorClient.new(ConveyorModel: Model)
    local self = setmetatable({}, ConveyorClient)

    self.Model = ConveyorModel
    self.Speed = 10
    self.Bags = {} 
    self.Spawn = ConveyorModel:WaitForChild("Spawn") :: BasePart 
    self.ConveyorId = ConveyorModel:GetAttribute("ConveyorId")

    BagSpawned.OnClientEvent:Connect(function(conveyorId, id, r, g, b, material)
        if conveyorId ~= self.ConveyorId then return end
        local start = self.Model:WaitForChild("Spawn") :: BasePart
        local rayOrigin = start.Position
        
        local rayResult = workspace:Raycast(
            rayOrigin,
            Vector3.new(0, -10, 0),
            RaycastParam
        )
        if not rayResult then return end
        local BagModelClone = BagModel:Clone()
        local originalSize = BagModelClone.Size
 
        local clickDetector = Instance.new("ClickDetector")
        clickDetector.Parent = BagModelClone

        clickDetector.MouseClick:Connect(function()
            print("Client clicked bag ID:", id, "on conveyor:", self.ConveyorId)
            BagClicked:Fire(self.ConveyorId, id)
        end)

        local groundY = rayResult and rayResult.Position.Y or rayOrigin.Y
        local spawnCFrame = CFrame.new(
            start.Position.X,
            groundY + originalSize.Y / 2,
            start.Position.Z
        ) * CFrame.fromMatrix(Vector3.zero, start.CFrame.XVector, start.CFrame.YVector)

        BagModelClone.Color = Color3.fromRGB(r, g, b)
        BagModelClone.Material = material
        BagModelClone.Size = Vector3.new(0, 0, 0)
        BagModelClone.CFrame = spawnCFrame
        BagModelClone.Parent = workspace

        TweenService:Create(BagModelClone, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = originalSize
        }):Play()

        self.Bags[id] = { Part = BagModelClone, Distance = 0, OriginalSize = originalSize, GroundY = groundY }
    end)

    BagDeleted.OnClientEvent:Connect(function(conveyorId, id)
        if conveyorId ~= self.ConveyorId then return end
        local bag = self.Bags[id]
        if not bag then return end
        self.Bags[id] = nil

        local tween = TweenService:Create(bag.Part, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
            Size = Vector3.new(0, 0, 0)
        })
        tween:Play()
        tween.Completed:Once(function()
            bag.Part:Destroy()
        end)
    end)

    RunService.Heartbeat:Connect(function(dt)
        self.Advance(self, dt)
    end)

    return self
end

function ConveyorClient.Advance(self, dt: number)
    local spawn = self.Spawn
    if not spawn then return end

    local parts = {}
    local cframes = {}

    for _, bag in self.Bags do
        if bag.Part then
            bag.Distance += self.Speed * dt

            local targetCFrame = CFrame.new(
                spawn.Position.X,
                bag.GroundY + bag.OriginalSize.Y / 2,
                spawn.Position.Z
            )
            * CFrame.fromMatrix(Vector3.zero, spawn.CFrame.XVector, spawn.CFrame.YVector)
            + spawn.CFrame.LookVector * bag.Distance

            local newCFrame = bag.Part.CFrame:Lerp(targetCFrame, math.min(dt * 15, 1))

            table.insert(parts, bag.Part)
            table.insert(cframes, newCFrame)
        end
    end

    if #parts > 0 then
        workspace:BulkMoveTo(parts, cframes, Enum.BulkMoveMode.FireCFrameChanged) -- Optimization
    end
end

function ConveyorClient.Init()
    for _, ConveyorModel in Conveyors:GetChildren() do
        ConveyorClient.new(ConveyorModel)
    end
end

return ConveyorClient