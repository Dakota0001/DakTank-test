AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

ENT.DakMaxHealth = 10
ENT.DakHealth = 10
ENT.DakName = "Turret Control"
ENT.DakContraption = {}
ENT.DakTurretMotor = nil

function ENT:ApplyForce(entity, angle)
	local phys = entity:GetPhysicsObject()

	local up = entity:GetUp()
	local left = entity:GetRight() * -1
	local forward = entity:GetForward()

	if angle.pitch ~= 0 then
		local pitch = up      * (angle.pitch * 0.5)
		phys:ApplyForceOffset( forward, pitch )
		phys:ApplyForceOffset( forward * -1, pitch * -1 )
	end
	if angle.yaw ~= 0 then
		local yaw   = forward * (angle.yaw * 0.5)
		phys:ApplyForceOffset( left, yaw )
		phys:ApplyForceOffset( left * -1, yaw * -1 )
	end
	if angle.roll ~= 0 then
		local roll  = left    * (angle.roll * 0.5)
		phys:ApplyForceOffset( up, roll )
		phys:ApplyForceOffset( up * -1, roll * -1 )
	end
end


function ENT:Initialize()
	self:SetModel( "models/beer/wiremod/gate_e2_mini.mdl" )
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self.DakHealth = self.DakMaxHealth
	self.DakArmor = 10
	local phys = self:GetPhysicsObject()
	self.timer = CurTime()

	if(IsValid(phys)) then
		phys:Wake()
	end

	self.Inputs = Wire_CreateInputs(self, { "Active", "Gun [ENTITY]", "Turret [ENTITY]", "CamHitPos [VECTOR]", "CamAngle [ANGLE]" })
	self.Soundtime = CurTime()
 	self.SparkTime = CurTime()
 	self.SlowThinkTime = CurTime()
 	self.RotMult = 1.2
end

function ENT:Think()
	if self.DakTurretMotor == nil then
		self.RotMult = 2
	else
		self.RotMult = 4
	end

	if #self.DakContraption > 0 then
		if IsValid(self.Inputs.Gun.Value) then
			self.RotationSpeed = self.RotMult * (3000/self.Inputs.Gun.Value:GetPhysicsObject():GetMass())

			self.Elevation = self:GetElevation()
			self.Depression = self:GetDepression()
			self.YawMin = self:GetYawMin()
			self.YawMax = self:GetYawMax()

			self.DakActive = self.Inputs.Active.Value
			if IsValid(self.Inputs.Gun.Value:GetParent()) then
				if IsValid(self.Inputs.Gun.Value:GetParent():GetParent()) then
					self.DakGun = self.Inputs.Gun.Value:GetParent():GetParent()
				end
			else
				self.DakGun = self.Inputs.Gun.Value
			end
			self.DakTurret = self.Inputs.Turret.Value
			self.DakCamHitPos = self.Inputs.CamHitPos.Value
			self.DakCamAngle = self.Inputs.CamAngle.Value
			if self.DakActive > 0 then
				local trace = {}
				trace.start = self.DakCamHitPos
				trace.endpos = self.DakCamHitPos + (self.DakCamAngle:Forward() * 9999999)
				trace.filter = self.DakContraption
				local Hit = util.TraceLine( trace )
				self.GunAng = (Hit.HitPos-self.DakGun:GetPos()):Angle()
				self.RotAngle = Angle(math.Clamp(self.DakGun:WorldToLocalAngles(self.GunAng).pitch,-self.RotationSpeed,self.RotationSpeed),math.Clamp(self.DakGun:WorldToLocalAngles(self.GunAng).yaw,-self.RotationSpeed,self.RotationSpeed),math.Clamp(self.DakGun:WorldToLocalAngles(self.GunAng).roll,-self.RotationSpeed,self.RotationSpeed))
				self.ClampAngle = Angle(math.Clamp(self:WorldToLocalAngles(self.DakGun:LocalToWorldAngles(self.RotAngle)).pitch,-self.Elevation,self.Depression),math.Clamp(self:WorldToLocalAngles(self.DakGun:LocalToWorldAngles(self.RotAngle)).yaw,-self.YawMin,self.YawMax),math.Clamp(self:WorldToLocalAngles(self.DakGun:LocalToWorldAngles(self.RotAngle)).roll,-1,1))
				self.PreAngle = ((self.DakGun:WorldToLocalAngles(self:LocalToWorldAngles(self.ClampAngle)) * 250) - (Angle(self.DakGun:GetPhysicsObject():GetAngleVelocity().y,self.DakGun:GetPhysicsObject():GetAngleVelocity().z,self.DakGun:GetPhysicsObject():GetAngleVelocity().x) * 50))

				self.PostAngle = Angle(self.PreAngle.pitch * self.DakGun:GetPhysicsObject():GetInertia().y,self.PreAngle.yaw * self.DakGun:GetPhysicsObject():GetInertia().z,self.PreAngle.roll * self.DakGun:GetPhysicsObject():GetInertia().x)
				self:ApplyForce(self.DakGun, self.PostAngle)
				if IsValid(self.DakTurret) then
					self:ApplyForce(self.DakTurret, Angle(0,self.PostAngle.yaw,0))
				end

				self.DakGun:GetPhysicsObject():AddAngleVelocity(self:GetParent():GetParent():GetPhysicsObject():GetAngleVelocity())
				if IsValid(self.DakTurret) then
					self.DakTurret:GetPhysicsObject():AddAngleVelocity((self.DakGun:GetPhysicsObject():GetMass()/(self.DakTurret:GetPhysicsObject():GetMass()*2))*self:GetParent():GetParent():GetPhysicsObject():GetAngleVelocity())
				end
			else
				self.GunAng = self:GetAngles()
				self.RotAngle = Angle(math.Clamp(self.DakGun:WorldToLocalAngles(self.GunAng).pitch,-self.RotationSpeed,self.RotationSpeed),math.Clamp(self.DakGun:WorldToLocalAngles(self.GunAng).yaw,-self.RotationSpeed,self.RotationSpeed),math.Clamp(self.DakGun:WorldToLocalAngles(self.GunAng).roll,-self.RotationSpeed,self.RotationSpeed))
				self.ClampAngle = Angle(math.Clamp(self:WorldToLocalAngles(self.DakGun:LocalToWorldAngles(self.RotAngle)).pitch,-self.Elevation,self.Depression),math.Clamp(self:WorldToLocalAngles(self.DakGun:LocalToWorldAngles(self.RotAngle)).yaw,-self.YawMin,self.YawMax),math.Clamp(self:WorldToLocalAngles(self.DakGun:LocalToWorldAngles(self.RotAngle)).roll,-1,1))
				self.PreAngle = ((self.DakGun:WorldToLocalAngles(self:LocalToWorldAngles(self.ClampAngle)) * 250) - (Angle(self.DakGun:GetPhysicsObject():GetAngleVelocity().y,self.DakGun:GetPhysicsObject():GetAngleVelocity().z,self.DakGun:GetPhysicsObject():GetAngleVelocity().x) * 50))
				self.PostAngle = Angle(self.PreAngle.pitch * self.DakGun:GetPhysicsObject():GetInertia().y,self.PreAngle.yaw * self.DakGun:GetPhysicsObject():GetInertia().z,self.PreAngle.roll * self.DakGun:GetPhysicsObject():GetInertia().x)
				self:ApplyForce(self.DakGun, self.PostAngle)
				if IsValid(self.DakTurret) then
					self:ApplyForce(self.DakTurret, Angle(0,self.PostAngle.yaw,0))
				end
				self.DakGun:GetPhysicsObject():AddAngleVelocity(self:GetParent():GetParent():GetPhysicsObject():GetAngleVelocity())
				if IsValid(self.DakTurret) then
					self.DakTurret:GetPhysicsObject():AddAngleVelocity((self.DakGun:GetPhysicsObject():GetMass()/(self.DakTurret:GetPhysicsObject():GetMass()*2))*self:GetParent():GetParent():GetPhysicsObject():GetAngleVelocity())
				end
			end
		end
	end
	self:NextThink(CurTime())
    return true
end

function ENT:PreEntityCopy()
	local info = {}
	local entids = {}

	if IsValid(self.DakTurretMotor) then
		info.TurretMotorID = self.DakTurretMotor:EntIndex()
	end

	info.DakName = self.DakName
	info.DakHealth = self.DakHealth
	info.DakMaxHealth = self.DakBaseMaxHealth
	info.DakMass = self.DakMass
	info.DakOwner = self.DakOwner
	duplicator.StoreEntityModifier( self, "DakTek", info )
	//Wire dupe info
	self.BaseClass.PreEntityCopy( self )
end

function ENT:PostEntityPaste( Player, Ent, CreatedEntities )
	if (Ent.EntityMods) and (Ent.EntityMods.DakTek) then

		local TurretMotor = CreatedEntities[ Ent.EntityMods.DakTek.TurretMotorID ]
		if TurretMotor and IsValid(TurretMotor) then
			self.DakTurretMotor = TurretMotor
		end

		self.DakName = Ent.EntityMods.DakTek.DakName
		self.DakHealth = Ent.EntityMods.DakTek.DakHealth
		self.DakMaxHealth = Ent.EntityMods.DakTek.DakMaxHealth
		self.DakMass = Ent.EntityMods.DakTek.DakMass
		self.DakOwner = Player
		Ent.EntityMods.DakTek = nil
	end
	self.BaseClass.PostEntityPaste( self, Player, Ent, CreatedEntities )
end