--[[

    ______                                             __      _    ____ __
   / ____/________ _____ ___  ___ _      ______  _____/ /__   | |  / / // /
  / /_  / ___/ __ `/ __ `__ \/ _ \ | /| / / __ \/ ___/ //_/   | | / / // /_
 / __/ / /  / /_/ / / / / / /  __/ |/ |/ / /_/ / /  / ,<      | |/ /__  __/
/_/   /_/   \__,_/_/ /_/ /_/\___/|__/|__/\____/_/  /_/|_|     |___/  /_/   
                                                                           

Author: wntvy
Date: 3/31/2021

--]]

-- last updated 01/11/2022
-- NOT FINISHED AT ALL LOL

-- Services

local Rep = game:GetService("ReplicatedStorage"); local RS = game:GetService("RunService"); local UIS = game:GetService("UserInputService");

-- Folders in ReplicatedStorage

local Modules1 = Rep["Modules_1"]; local Modules2 = Rep["Modules_2"];

-- Modules

local gunFunctions = require(Modules1.GunFunctions)

-- Weapons

local primaryProperties = nil
local secondaryProperties = nil
local knifeProperties = nil

local currentWeapon = nil
local currentGunModel = nil

local weaponAmmo, weaponAmmoReserve, weaponAmmoCapacity, fireMode = nil, nil, nil, nil

-- Player Variables

local Players = game:GetService("Players"); local Player = Players.LocalPlayer; local Char = Player.Character or Player.Character:Wait();

local Mouse = Player:GetMouse()
local MouseDown = false
local Cam = workspace.CurrentCamera

UIS.MouseIconEnabled = false
Player.CameraMode = Enum.CameraMode.LockFirstPerson

-- Keybinds Setting

local keys = {
	["Primary"] = Enum.KeyCode.One; ["Secondary"] = Enum.KeyCode.Two; ["Knife"] = Enum.KeyCode.Three;
	["Mode"] = Enum.KeyCode.V; ["LeanState1"] = Enum.KeyCode.Q; ["LeanState2"] = Enum.KeyCode.E; ["Shoot"] = Enum.UserInputType.MouseButton1;
	["Aim"] = Enum.UserInputType.MouseButton2; ["Sprint"] = Enum.KeyCode.LeftShift; ["Reload"] = Enum.KeyCode.R; ["ExitFramework"] = Enum.KeyCode.X
}

-- Setup Functions

function setupGun(classOfWeapon, mainCFrame, aimCFrame, sprintCFrame, shootingAnim, reloadAnim, holdAnim, handlingSpeed, bulletVelocity, dmg, headDmg, ammo, ammoReserve, firerate, capacity, weaponName, model, constantAcceleration, modeTable, fireSound)
	local newGun = {}
	table.insert(newGun, 1, classOfWeapon);table.insert(newGun, 2, mainCFrame);table.insert(newGun, 3, aimCFrame);table.insert(newGun, 4, sprintCFrame);table.insert(newGun, 5, shootingAnim);table.insert(newGun, 6, reloadAnim);table.insert(newGun, 7, holdAnim);table.insert(newGun, 8, handlingSpeed);table.insert(newGun, 9, bulletVelocity);table.insert(newGun, 10, dmg);table.insert(newGun, 11, headDmg);table.insert(newGun, 12, ammo);table.insert(newGun, 13, ammoReserve);table.insert(newGun, 14, firerate);table.insert(newGun, 15, capacity);table.insert(newGun, 16, weaponName);table.insert(newGun, 17, model);table.insert(newGun, 18, constantAcceleration);table.insert(newGun, 19, modeTable);table.insert(newGun, 20, fireSound)
	return newGun
end

-- Main

primaryProperties = setupGun(
	"Primary", -- weapon class
	CFrame.new(2, -1, 0), -- position of gun on screen
	CFrame.new(-1.9, 0.7, 1.3), -- position of gun when aiming
	CFrame.new(-0.3, -0.2, 0.6) * CFrame.Angles(0, math.rad(20), 0), -- position of gun when sprinting
	{"rbxassetid://5596859162", true, CFrame.new(0,0,1)*CFrame.Angles(math.rad(1), 0, 0)}, -- shooting animation (TRUE if CFrame based shooting, FALSE if animation based shooting)
	"rbxassetid://5596629936", -- reload animtion
	"rbxassetid://5595961900", -- hold animation
	0.9, -- handling speed (normal is 1)
	500, -- bullet velocity (studs per second)
	20, -- damage
	40, -- headshot damage
	30, -- ammo in the gun
	150, -- reserve ammo
	1200, -- firerate (NOT ACCURATE AT ALL)
	30, -- ammo capacity
	"Honey Badger", -- gun name
	Rep.GunModels["Honey Badger"], -- gun model
	Vector3.new(0, -workspace.Gravity, 0), -- constant acceleration (dont change)
	{"Auto", "Semi"},
	"rbxassetid://5541424023" -- shooting sound
)

secondaryProperties = setupGun(
	"Secondary", -- weapon class
	CFrame.new(2, -1, 0), -- position of gun on screen
	CFrame.new(-1.9, 0.7, 1.3), -- position of gun when aiming
	CFrame.new(-0.3, -0.2, 0.6) * CFrame.Angles(0, math.rad(20), 0), -- position of gun when sprinting
	{"rbxassetid://5596859162", true, CFrame.new(0,0,1)*CFrame.Angles(math.rad(1), 0, 0)}, -- shooting animation (TRUE if CFrame based shooting, FALSE if animation based shooting)
	"rbxassetid://5596629936", -- reload animtion
	"rbxassetid://5595961900", -- hold animation
	0.9, -- handling speed (normal is 1)
	500, -- bullet velocity (studs per second)
	50, -- damage
	40, -- headshot damage
	100, -- ammo in the gun
	1000, -- reserve ammo
	2000, -- firerate (NOT ACCURATE AT ALL)
	100, -- ammo capacity
	"Honey Badger V2", -- gun name
	Rep.GunModels["Honey Badger V2"], -- gun model
	Vector3.new(0, -workspace.Gravity, 0), -- constant acceleration (dont change)
	{"Auto", "Semi"},
	"rbxassetid://5541424023" -- shooting sound
)

-- RenderStepped

RS.RenderStepped:Connect(function()
	if currentWeapon and currentGunModel then
		currentGunModel:SetPrimaryPartCFrame(currentWeapon:SnapToMainPos(Cam))
	end

	if currentWeapon and weaponAmmo and weaponAmmoCapacity and weaponAmmoReserve and fireMode then
		weaponAmmo = currentWeapon.Ammo
		weaponAmmoReserve = currentWeapon.AmmoReserve
		weaponAmmoCapacity = currentWeapon.Capacity
		local ammoText = Player.PlayerGui.Main.AmmoText
		local gunText = Player.PlayerGui.Main.GunText
		local modeText = Player.PlayerGui.Main.ModeText
		gunText.Text = currentGunModel.Name
		ammoText.Text = weaponAmmo .. "/" .. weaponAmmoReserve
		modeText.Text = "[" .. fireMode .. "]"
	else
		local ammoText = Player.PlayerGui.Main.AmmoText
		local gunText = Player.PlayerGui.Main.GunText
		local modeText = Player.PlayerGui.Main.ModeText
		modeText.Text = ""
		gunText.Text = ""
		ammoText.Text = ""
	end
end)

-- UIS

UIS.InputBegan:Connect(function(input, typing)
	if not typing then
		if input.KeyCode == keys["Primary"] then
			if currentGunModel then
				if primaryProperties[16] == currentGunModel.Name then
					print("already equipped primary")
				else
					currentGunModel:Destroy()
					currentGunModel = nil
					currentWeapon, weaponAmmo, weaponAmmoReserve, weaponAmmoCapacity, fireMode = gunFunctions.New(primaryProperties, Player)
					currentGunModel = currentWeapon:SetupGun()
				end
			else
				currentWeapon, weaponAmmo, weaponAmmoReserve, weaponAmmoCapacity, fireMode = gunFunctions.New(primaryProperties, Player)
				currentGunModel = currentWeapon:SetupGun()
			end
		end
		
		if input.KeyCode == keys["Secondary"] then
			if currentGunModel then
				if secondaryProperties[16] == currentGunModel.Name then
					print("already equipped secondary")
				else
					currentGunModel:Destroy()
					currentGunModel = nil
					currentWeapon, weaponAmmo, weaponAmmoReserve, weaponAmmoCapacity, fireMode = gunFunctions.New(secondaryProperties, Player)
					currentGunModel = currentWeapon:SetupGun()
				end
			else
				currentWeapon, weaponAmmo, weaponAmmoReserve, weaponAmmoCapacity, fireMode = gunFunctions.New(primaryProperties, Player)
				currentGunModel = currentWeapon:SetupGun()
			end
		end
		
		if input.KeyCode == keys["Knife"] then
			
		end
	end
end)

UIS.InputBegan:Connect(function(input, typing)
	if not typing and currentWeapon and currentGunModel then
		-- gun function keybinds
		if input.UserInputType == keys["Shoot"] then
			MouseDown = true
			if currentWeapon.CurrentMode == "Auto" then
				while MouseDown do
					currentWeapon:Shoot()
					wait()
				end
			else
				if currentWeapon.CurrentMode == "Semi" then
					if not currentWeapon.Shooting then
						currentWeapon:Shoot()
						wait()
					end
				end
			end
		end
		
		if input.UserInputType == keys["Aim"] then
			currentWeapon:Aim(true)
		end
		
		if input.KeyCode == keys["Reload"] then
			currentWeapon:Reload()
		end
		
		if input.KeyCode == keys["Mode"] then
			fireMode = currentWeapon:ChangeMode()
		end
		
		if input.KeyCode == keys["LeanState1"] then
			currentWeapon:Lean(1)
		end
		
		if input.KeyCode == keys["LeanState2"] then
			currentWeapon:Lean(2)
		end
		
		if input.KeyCode == keys["Sprint"] then
			currentWeapon:Sprint(true)
			Char.Humanoid.WalkSpeed = 22
		end
		
		if input.KeyCode == keys["ExitFramework"] then
			currentWeapon, currentGunModel = currentWeapon:Remove()
			currentGunModel:Destroy()
		end
	end
end)

UIS.InputEnded:Connect(function(input, typing)
	if not typing and currentWeapon and currentGunModel then
		if input.UserInputType == keys["Aim"] then
			currentWeapon:Aim(false)
		end
		
		if input.UserInputType == keys["Shoot"] then
			MouseDown = false
		end
		
		if input.KeyCode == keys["Sprint"] then
			currentWeapon:Sprint(false)
			Char.Humanoid.WalkSpeed = 16
		end
		
		if input.KeyCode == keys["LeanState1"] then
			currentWeapon:EndLean()
		end

		if input.KeyCode == keys["LeanState2"] then
			currentWeapon:EndLean()
		end
	end
end)
