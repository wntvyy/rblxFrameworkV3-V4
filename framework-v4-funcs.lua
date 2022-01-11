local gun = {}
gun.__index = gun

function gun.New(gunProperties, player)
	local newGun = {}
	setmetatable(newGun, gun)
	
	-- set properties
	
	newGun.Class = gunProperties[1]
	newGun.MainCFrame = gunProperties[2]
	newGun.AimCFrame = gunProperties[3]
	newGun.SprintCFrame = gunProperties[4]
	newGun.ShootingAnim = gunProperties[5]
	newGun.ReloadAnim = gunProperties[6]
	newGun.HoldAnim = gunProperties[7]
	newGun.HandlingSpeed = gunProperties[8]
	newGun.BulletVelocity = gunProperties[9]
	newGun.Damage = gunProperties[10]
	newGun.HeadDamage = gunProperties[11]
	newGun.Ammo = gunProperties[12]
	newGun.AmmoReserve = gunProperties[13]
	newGun.Firerate = gunProperties[14]
	newGun.Capacity = gunProperties[15]
	newGun.Name = gunProperties[16]
	newGun.Model = gunProperties[17]
	newGun.ConstantAcceleration = gunProperties[18]
	newGun.ModeTable = gunProperties[19]
	newGun.FireSound = gunProperties[20]
	
	-- properties seperate from property table
	newGun.Position = CFrame.new()
	newGun.Aiming = false
	newGun.Shooting = false
	newGun.Leaning = false
	newGun.LeanState = nil
	newGun.Reloading = false
	newGun.CurrentMode = newGun.ModeTable[1]
	newGun.Sprinting = false
	
	if gunProperties[5][2] then
		newGun.CFrameShooting = gunProperties[5][3]
	else
		newGun.CFrameShooting = false
	end
	
	newGun.CFrameAim = CFrame.new()
	newGun.CFrameSprint = CFrame.new()
	newGun.CFrameShoot = CFrame.new()
	
	newGun.CFrameLean = CFrame.new()
	
	-- put in player
	newGun.Parent = workspace
	newGun.Owner = player.Character
	
	return newGun, newGun.Ammo, newGun.AmmoReserve, newGun.Capacity, newGun.CurrentMode
end

function gun:SetupGun()
	local newGunModel
	if self.Parent:FindFirstChild((self.Model).Name) then
		self.Parent:FindFirstChild((self.Model).Name):Destroy()
		newGunModel = self.Model:Clone()
		newGunModel.Parent = self.Parent
	else
		newGunModel = self.Model:Clone()
		newGunModel.Parent = self.Parent
	end 
	return newGunModel
end

function gun:SnapToMainPos(cam)
	self.Position = (cam.CFrame * self.MainCFrame * self.CFrameAim * self.CFrameSprint * self.CFrameShoot * self.CFrameLean)
	cam.CFrame = (cam.CFrame * self.CFrameLean)
	
	-- do cframes
	
	if self.Aiming then
		self.CFrameAim = self.CFrameAim:Lerp(self.AimCFrame, 0.2)
	else
		self.CFrameAim = self.CFrameAim:Lerp(CFrame.new(), 0.2)
	end
	
	if self.Sprinting then
		self.CFrameSprint = self.CFrameSprint:Lerp(self.SprintCFrame, 0.2)
		self.CFrameLean = self.CFrameLean:Lerp(CFrame.new(), 0.2)
	else
		self.CFrameSprint = self.CFrameSprint:Lerp(CFrame.new(), 0.2)
	end

	self.CFrameShoot = self.CFrameShoot:Lerp(CFrame.new(), 0.1)
	
	if self.LeanState == 1 and self.Leaning then
		self.CFrameLean = self.CFrameLean:Lerp(CFrame.Angles(0, 0, math.rad(30)) * CFrame.new(0.1, 0.5, 0), 0.2)
	end
	
	if self.LeanState == 2 and self.Leaning then
		self.CFrameLean = self.CFrameLean:Lerp(CFrame.Angles(0, 0, math.rad(-30)) * CFrame.new(0.1, 0.5, 0), 0.2)
	end
	
	if not self.Leaning then
		self.LeanState = nil -- just in case
		self.CFrameLean = self.CFrameLean:Lerp(CFrame.new(), 0.2)
	end
	
	return self.Position
end

function gun:ChangeMode()
	if #self.ModeTable > 1 and not self.Shooting and not self.Aiming and not self.Leaning and not self.Reloading then
		if self.CurrentMode == self.ModeTable[1] then
			self.CurrentMode = self.ModeTable[2]
		else
			self.CurrentMode = self.ModeTable[1]
		end
	else
		self.CurrentMode = self.ModeTable[1]
	end
	return self.CurrentMode
end

--[[

function gun:SubtractAmmo(amount)
	self.Ammo = self.Ammo - amount
	return self.Ammo
end

--]]

function gun:PlayAnimation(animation, part)
	
end

function gun:Reload()
	if self.Ammo < self.Capacity and not self.Aiming and not self.Shooting and not self.Leaning and not self.Reloading then
		self.Reloading = true
		self.CFrameLean = self.CFrameLean:Lerp(CFrame.new(), 0.2)
		if self.Ammo <= self.Capacity then
			local calculated = math.min(self.Capacity - self.Ammo, self.AmmoReserve)			
			self.Ammo = self.Ammo + calculated
			self.AmmoReserve = self.AmmoReserve - calculated
		else
			self.Reloading = false
		end
	end
	self.Reloading = false
	return self.Ammo
end

function shootingSound(object)
	local newSound = Instance.new("Sound", workspace)
	newSound.SoundId = object.FireSound
	newSound:Play()
	game.Debris:AddItem(newSound, 0.9)
end

function gun:Shoot()
	if not self.Reloading and not self.Shooting and self.Ammo > 0 then
		self.CFrameLean = self.CFrameLean:Lerp(CFrame.new(), 0.2)
		if self.CFrameShooting then
			-- cframed shooting
			self.CFrameShoot = self.CFrameShooting
			self.Shooting = true
			shootingSound(self)
			self.Ammo = math.clamp(self.Ammo-1, -1, self.Capacity+1)
			wait(60/self.Firerate)
			self.Shooting = false
		else
			-- animated shooting
			self.Shooting = true
			shootingSound(self)
			self.Ammo = math.clamp(self.Ammo-1, -1, self.Capacity+1)
			wait(60/self.Firerate)
			self.Shooting = false
		end
	end
	return self.Ammo
end

function gun:Aim(bool)
	if not self.Sprinting then
		self.Aiming = bool
		return self.Aiming
	end
end

function gun:Sprint(bool)
	if not self.Aiming and not self.Shooting then
		self.Sprinting = bool
		return self.Sprinting
	end
end

-- lean

function gun:EndLean()
	self.Leaning = false
	self.LeanState = nil
end

function gun:Lean(leanstate)
	if self.Aiming then
		self.Leaning = true
		self.LeanState = leanstate
	end
end

-- exit framework functions

function destroyAllGunModels(gunName) -- idk why i made this but whatever
	return workspace:FindFirstChild(gunName)
end

function gun:Remove()
	local model = destroyAllGunModels(self.Model.Name)
	for i, v in next, self do
		v = nil
	end
	self = nil
	return self, model
end

return gun
