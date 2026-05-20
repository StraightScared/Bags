--!strict
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packet = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("Packet"))

local SliderPacket = Packet("SliderValue", Packet.NumberU8)

local Slider = {}
Slider.__index = Slider

export type Slider = typeof(setmetatable({} :: {
	Bar: Frame,
	Handle: GuiObject,
	Fill: Frame,
	MinValue: number,
	MaxValue: number,
	IsDragging: boolean,
	Value: number,
}, Slider))

function Slider.new(gui: ScreenGui, min: number?, max: number?): Slider
    local self = setmetatable({}, Slider)

	local SliderContainer = gui:WaitForChild("SliderContainer")
	local Bar = SliderContainer:WaitForChild("Bar")

	self.Bar = Bar
    self.Handle = SliderContainer:WaitForChild("Handle")
    self.Fill = Bar:WaitForChild("Fill")
    self.MinValue = min or 0
    self.MaxValue = max or 100
    self.IsDragging = false
    self.Value = 0,

	self:ConnectInputs()
	return self
end

function Slider:Update(inputPosition: Vector3)
	local relativeX = inputPosition.X - self.Bar.AbsolutePosition.X
	local percentage = math.clamp(relativeX / self.Bar.AbsoluteSize.X, 0, 1)

	self.Handle.Position = UDim2.new(percentage, 0, self.Handle.Position.Y.Scale, self.Handle.Position.Y.Offset)
	self.Fill.Size = UDim2.new(percentage, 0, 1, 0)

	local newValue = math.floor(self.MinValue + (self.MaxValue - self.MinValue) * percentage)
	if newValue ~= self.Value then
		self.Value = newValue
		SliderPacket:Fire(newValue)
	end
end

function Slider:ConnectInputs()
	self.Handle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 
			or input.UserInputType == Enum.UserInputType.Touch then
			self.IsDragging = true
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 
			or input.UserInputType == Enum.UserInputType.Touch then
			self.IsDragging = false
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if self.IsDragging and (input.UserInputType == Enum.UserInputType.MouseMovement 
			or input.UserInputType == Enum.UserInputType.Touch) then
			self:Update(input.Position)
		end
	end)
end

return Slider