local PlayersService = game:GetService('Players')
local RootCameraCreator = require(script.Parent)

local XZ_VECTOR = Vector3.new(1,0,1)


local function IsFinite(num)
	return num == num and num ~= 1/0 and num ~= -1/0
end

-- May return NaN or inf or -inf
-- This is a way of finding the angle between the two vectors:
local function findAngleBetweenXZVectors(vec2, vec1)
	return math.atan2(vec1.X*vec2.Z-vec1.Z*vec2.X, vec1.X*vec2.X + vec1.Z*vec2.Z)
end

local function CreateAttachCamera()
	local module = RootCameraCreator()
	module:ConnectInputEvents()
	module.PanEnabled = false
	module.KeyPanEnabled = false
	
	local lastUpdate = tick()
	function module:Update()
		local now = tick()
		
		local camera = 	workspace.CurrentCamera
		local player = PlayersService.LocalPlayer
		
		if lastUpdate == nil or now - lastUpdate > 1 then
			module:ResetCameraLook()
			self.LastCameraTransform = nil
		end	
		
		local subjectPosition = self:GetSubjectPosition()		
		if subjectPosition and player and camera then
			local zoom = self:GetCameraZoom()
			if zoom <= 0 then
				zoom = 0.1
			end
			
			if self.LastCameraTransform then
				local humanoid = self:GetHumanoid()
				if lastUpdate and humanoid and humanoid.Torso then
					local forwardVector = humanoid.Torso.CFrame.lookVector

					local y = findAngleBetweenXZVectors(forwardVector, self:GetCameraLook())
					if IsFinite(y) and math.abs(y) > 0.0001 then
						self:RotateCamera(self:GetCameraLook(), Vector3.new(y, 0, 0))
					end
				end
			end
			
			camera.Focus = CFrame.new(subjectPosition)
			camera.CoordinateFrame = CFrame.new(camera.Focus.p - (zoom * self:GetCameraLook()), camera.Focus.p)
			self.LastCameraTransform = camera.CoordinateFrame
		end
		lastUpdate = now
	end
	
	return module
end

return CreateAttachCamera
