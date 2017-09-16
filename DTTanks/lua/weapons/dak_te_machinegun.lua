AddCSLuaFile( "dak_ai_translations.lua" )
include( "dak_ai_translations.lua" )

if SERVER then
 
	--AddCSLuaFile ("shared.lua")
 

	SWEP.Weight = 5

	SWEP.AutoSwitchTo = false
	SWEP.AutoSwitchFrom = false
 
elseif CLIENT then
 
	SWEP.PrintName = "DTTE Machine Gun"
 
	SWEP.Slot = 4
	SWEP.SlotPos = 1

	SWEP.DrawAmmo = true
	SWEP.DrawCrosshair = true
end
 
SWEP.Author = "DakTank"
SWEP.Purpose = "Shoots Things."
SWEP.Instructions = "20mm average pen"

SWEP.Category = "DakTank"
 
SWEP.Spawnable = true
SWEP.AdminOnly = true
 
SWEP.ViewModel = "models/weapons/cstrike/c_mach_m249para.mdl"
SWEP.WorldModel = "models/weapons/w_mach_m249para.mdl"

SWEP.Primary.ClipSize		= 100
SWEP.Primary.DefaultClip	= 1000
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "AR2"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"
 
SWEP.PrimaryNumberofShots = 1
SWEP.PrimarySpread = 0.005
SWEP.PrimaryForce = 30
SWEP.PrimaryDamage = 30
SWEP.PrimaryCooldown = 0.05
SWEP.UseHands = true

SWEP.HoldType = "ar2"
SWEP.CSMuzzleFlashes = true

function SWEP:Initialize()
	self:SetHoldType( self.HoldType )
	if self.Owner:IsNPC() then
		if SERVER then
		self.Owner:SetCurrentWeaponProficiency( WEAPON_PROFICIENCY_PERFECT )
		self.Owner:CapabilitiesAdd( CAP_MOVE_GROUND )
		self.Owner:CapabilitiesAdd( CAP_MOVE_JUMP )
		self.Owner:CapabilitiesAdd( CAP_MOVE_CLIMB )
		self.Owner:CapabilitiesAdd( CAP_MOVE_SWIM )
		self.Owner:CapabilitiesAdd( CAP_MOVE_CRAWL )
		self.Owner:CapabilitiesAdd( CAP_MOVE_SHOOT )
		self.Owner:CapabilitiesAdd( CAP_USE )
		self.Owner:CapabilitiesAdd( CAP_USE_SHOT_REGULATOR )
		self.Owner:CapabilitiesAdd( CAP_SQUAD )
		self.Owner:CapabilitiesAdd( CAP_DUCK )
		self.Owner:CapabilitiesAdd( CAP_AIM_GUN )
		self.Owner:CapabilitiesAdd( CAP_NO_HIT_SQUADMATES )
		end
	end
	self.PrimaryLastFire = 0
	self.Fired = 0
end

function SWEP:Reload()
	if  ( self.Weapon:Clip1() < self.Primary.ClipSize && self.Owner:GetAmmoCount( self.Primary.Ammo ) > 0 ) then
		self.Weapon:DefaultReload(ACT_VM_RELOAD)	
	end
end
 
function SWEP:Think()
end

function SWEP:PrimaryAttack()
	if self.PrimaryLastFire+self.PrimaryCooldown<CurTime() then
		if self.Weapon:Clip1() > 0 then
			if SERVER then
				local shootOrigin = self.Owner:EyePos()
				local shootDir = self.Owner:GetAimVector()
				local shell = ents.Create( "dak_tankshell" )
				if ( !IsValid( shell ) ) then return end

				shell:SetPos(self.Owner:EyePos())
				shell:SetAngles( shootDir:Angle() + Angle(math.Rand(-0.25,0.25),math.Rand(-0.25,0.25),math.Rand(-0.25,0.25)) )

				shell.DakTrail = "dakshelltrail"
				shell.DakVelocity = 30000
				shell.DakDamage = 0.075
				shell.DakMass = 2
				shell.DakIsPellet = false
				shell.DakSplashDamage = 0
				shell.DakPenetration = 20
				shell.DakExplosive = false
				shell.DakBlastRadius = 0
				shell.DakPenSounds = {"daktanks/daksmallpen1.wav","daktanks/daksmallpen2.wav","daktanks/daksmallpen3.wav","daktanks/daksmallpen4.wav"}

				shell.DakBasePenetration = 20

				shell.DakCaliber = 10

				shell.DakGun = self.Owner
				shell.DakGun.DakOwner = self.Owner
				shell:SetCollisionGroup(10)
				shell:Spawn()
			end
			self:EmitSound( "weapons/m249/m249-1.wav", 140, 100, 1, 2)
			self.PrimaryLastFire = CurTime()
			self:TakePrimaryAmmo(1)
			self.Fired = 1
		else
			self:Reload()
		end
	end

	if self.Fired == 1 then
		self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
		self.Fired = 0
	end
end

function SWEP:SecondaryAttack()
	if self.Owner:GetFOV()==40 then
		self.Owner:SetFOV( 0, 0.1 )
	else
		self.Owner:SetFOV( 40, 0.1 )
	end
end
 
function SWEP:AdjustMouseSensitivity()
	if math.Round(self.Owner:GetFOV(),0)==40 then
		return 0.40
	else
		return 1
	end
end

function SWEP:GetCapabilities()
	return bit.bor( CAP_WEAPON_RANGE_ATTACK1, CAP_INNATE_RANGE_ATTACK1 )
end


