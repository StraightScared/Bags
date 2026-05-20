local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Modules = ServerStorage:WaitForChild("Modules")

local Packet = require(ReplicatedStorage.Modules.Packet)
local SliderPacket = Packet("SliderValue", Packet.NumberU8)

-- For testing purposes
SliderPacket.OnServerEvent:Connect(function(player, value)
    print(player.Name, "slider:", value)
end)

for _, module in Modules:GetChildren() do
    local requiredModule = require(module)
    requiredModule.Init()
end

Players.PlayerAdded:Connect(function(Player)
    
end)