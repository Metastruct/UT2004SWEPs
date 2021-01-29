AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

function ENT:SpawnFunction(ply, tr)
	if (!tr.Hit) then return end
	local SpawnPos = tr.HitPos + tr.HitNormal * 32
	local ent = ents.Create(self.ClassName)
	ent:SetPos(SpawnPos)
	ent:Spawn()
	ent:Activate()
	return ent
end

function ENT:Initialize()
	util.PrecacheSound(self.PickupSound)
	self:SetModel(self.model)
	self:SetModelScale(0.4, 0) 
	self:SetMoveType(MOVETYPE_NONE)
	self:SetAngles(Angle(0,90,0))
	self:DrawShadow(true)
	self.Available = true
	self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
	self:SetRenderMode(RENDERMODE_TRANSALPHA)
	self:SetTrigger(true)
	self:UseTriggerBounds(true, 8)
end

function ENT:Think()
	if self.ReEnabled and CurTime() >= self.ReEnabled then
		self.ReEnabled = nil
		self.Available = true
		self:SetNoDraw(false)
		self:EmitSound("ut2004/weaponsounds/BWeaponSpawn1.wav")
		local effectdata = EffectData()
		effectdata:SetEntity(self)
		effectdata:SetOrigin(self:GetPos())
		util.Effect("propspawn", effectdata, true, true)
	end
end

function ENT:StartTouch(ent)
	if IsValid(ent) and ent:IsPlayer() and ent:Alive() and self.Available then
		local ammoCount = ent:GetAmmoCount(self.AmmoType)
		local ammoGiven = false
		
		if !ent:HasWeapon(self.WeapName) then
			ent:Give(self.WeapName)
			if !self.ShouldVanish then
				ent:EmitSound(self.PickupSound,85,100)
			end
			ammoCount = ent:GetAmmoCount(self.AmmoType)
			ammoGiven = true
			if ammoCount > self.MaxAmmo then
				ent:SetAmmo(self.MaxAmmo, self.AmmoType)
			end
		end
		
		if self.ShouldVanish or !cvars.Bool("ut2k4_weaponsstay") then
			self.Available = false
			self:SetNoDraw(true)
			self.ReEnabled = CurTime() + 25
			ent:EmitSound(self.PickupSound,85,100)
			if !ammoGiven and ammoCount < self.MaxAmmo then
				ent:SetAmmo(math.min(ammoCount + self.AmmoAmount, self.MaxAmmo), self.AmmoType)
			end
		end
		
		ent:SetNWFloat("ut2004itempickup", CurTime())
	end
end