AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

ENT.RespawnTime = 27

function ENT:SetupDataTables()
	self:NetworkVar( "Bool", 0, "Available" )
end

function ENT:SpawnFunction(ply, tr)
	if (!tr.Hit) then return end
	local SpawnPos = tr.HitPos + tr.HitNormal * 40
	local ent = ents.Create(self.ClassName)
	ent:SetPos(SpawnPos)
	ent:Spawn()
	ent:Activate()
	return ent
end

function ENT:Initialize()
	self:SetModel(self.model)
	--self:SetModelScale(0.4, 0) 
	self:SetMoveType(MOVETYPE_NONE)
	self:SetAngles(Angle(0,90,0))
	self:DrawShadow(true)
	self:SetAvailable(true)
	self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
	self:SetRenderMode(RENDERMODE_TRANSALPHA)
	self:SetTrigger(true)
	self:UseTriggerBounds(true, 8)
end

function ENT:Think()
	if self.ReEnabled and CurTime() >= self.ReEnabled then
		self.ReEnabled = nil
		self:EmitSound("ut2004/weaponsounds/item_respawn.wav")
		ParticleEffect( "ut2004_item_respawn", self:WorldSpaceCenter(), Angle(0,0,0), self )
		timer.Simple(0.5, function()
			if IsValid(self) then
				self:SetAvailable(true)
				self:DrawShadow(true)
			end
		end)/*
		local effectdata = EffectData()
		effectdata:SetEntity(self)
		effectdata:SetOrigin(self:GetPos())
		util.Effect("entity_remove", effectdata, true, true)*/
	end
end

function ENT:StartTouch(ent)
	if IsValid(ent) and ent:IsPlayer() and ent:Alive() and self:GetAvailable() then
		self:SetAvailable(false)
		self:DrawShadow(false)
		self.ReEnabled = CurTime() + self.RespawnTime
		
		ent:EmitSound(self.PickupSound,85,100)
		
		if ent.UT2K4UShield or ent:Armor() > self.MaxArmor then
			ent:SetArmor(math.min((ent:Armor()+self.Aamount), 150))
		else
			ent:SetArmor(math.min((ent:Armor()+self.Aamount), self.MaxArmor))
		end
		
		ent:SetNWFloat("ut2004itempickup", CurTime())
	end
end