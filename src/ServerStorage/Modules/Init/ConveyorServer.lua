local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Map = workspace:WaitForChild("Map")
local Conveyors = Map:WaitForChild("Conveyors")
local Packet = require(ReplicatedStorage.Modules.Packet)

local SliderPacket    = Packet("SliderValue",       Packet.NumberU8)
local BagSpawned = Packet("BagSpawned", Packet.NumberU8, Packet.NumberU16, Packet.NumberU8, Packet.NumberU8, Packet.NumberU8, Packet.EnumItem)
local BagDeleted = Packet("BagDeleted", Packet.NumberU8, Packet.NumberU16)
local BagClicked      = Packet("BagClicked",        Packet.NumberU16)

local ConveyorServer = {}
ConveyorServer.__index = ConveyorServer

function ConveyorServer.new(ConveyorModel: Model)
    local self = setmetatable({}, ConveyorServer)

    self.Speed = 10  
    self.Rate = 1
    self.Model = ConveyorModel
    self.ConveyorId = ConveyorModel:GetAttribute("ConveyorId")
    self.Bags = {}  
    self.NextId = 0
    self.SpawnTimer = 0


    SliderPacket.OnServerEvent:Connect(function(_, value)
        self.Rate = math.max(value, 1) 
        self.SpawnTimer = 0 

    end)

    BagClicked.OnServerEvent:Connect(function(player, id)
        print(player.Name, "clicked bag ID:", id)
    end)

    RunService.Heartbeat:Connect(function(dt)
        self:Update(dt)
    end)

    return self
end

function ConveyorServer:Update(dt: number)
    self.SpawnTimer += dt
    local interval = 1 / self.Rate
    while self.SpawnTimer >= interval do
        self.SpawnTimer -= interval
        self:SpawnBag()
    end

    for id, bag in self.Bags do
        bag.Distance += self.Speed * dt
        if bag.Distance >= self.Model.PrimaryPart.Size.Z then -- I'm using the primary parts size which is the Belt of the model to get the distance the bag has to go to reach the end.
            self.Bags[id] = nil
            BagDeleted:Fire(self.ConveyorId,id)
        end
    end
end

function ConveyorServer:SpawnBag()
    local id = self.NextId
    self.NextId += 1 -- If theres enough bags since were wrapping via. a U16 techncially we could have an overflow to fix this we just take the remainder of the u16 number overflow which is 65535 

    local r = math.random(0, 255)
    local g = math.random(0, 255)
    local b = math.random(0, 255)
    local materials = {
        Enum.Material.SmoothPlastic,
        Enum.Material.Metal,
        Enum.Material.Fabric,
        Enum.Material.Wood,
        Enum.Material.Neon,
    }
    local material = materials[math.random(#materials)]

    self.Bags[id] = { Distance = 0 }
    BagSpawned:Fire(self.ConveyorId, id, r, g, b, material)
end

function ConveyorServer.Init()
    local id = 0
    for _, ConveyorModel in Conveyors:GetChildren() do
        id += 1
        ConveyorModel:SetAttribute("ConveyorId", id)
        ConveyorServer.new(ConveyorModel) -- remove the second one
    end
end
return ConveyorServer