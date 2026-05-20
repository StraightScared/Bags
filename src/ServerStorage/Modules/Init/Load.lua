local ServerStorage = game:GetService("ServerStorage")
local Assets = ServerStorage:WaitForChild("Assets")
local Load = {}

function Load.Init()
    local Map = Assets:WaitForChild("Map")
    Map.Parent = workspace
end

return Load