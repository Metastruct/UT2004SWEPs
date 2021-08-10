EFFECT.EndMat 		= Material(  "ut2004/effects/shock_sparkle" )
EFFECT.BeamMat 		= Material(  "ut2004/effects/ShockBeamTex" )

EFFECT.EndMat1 		= Material(  "particle/particle_glow_02" )
EFFECT.BeamMat1		= Material(  "ut2004/effects/ShockBeamGreyTex" )

function EFFECT:Init(data)
	if !IsValid(data:GetEntity()) then self:Remove() return end
	
	self.mins = Vector(math.min(data:GetOrigin().x, data:GetStart().x), math.min(data:GetOrigin().y, data:GetStart().y), math.min(data:GetOrigin().z, data:GetStart().z))
	self.maxs = Vector(math.max(data:GetOrigin().x, data:GetStart().x), math.max(data:GetOrigin().y, data:GetStart().y), math.max(data:GetOrigin().z, data:GetStart().z))
	self:SetRenderBoundsWS( self.mins, self.maxs )
	--print(self.mins, self.maxs)
	
	self:SetAngles(data:GetAngles())
	self:SetModel("models/ut2004/effects/shock_coil.mdl")
	self.Refract = 1
	
	self.EndPos = data:GetOrigin()
	self.StartPos = self:GetTracerShootPos(data:GetStart(), data:GetEntity(), 1)
	
	self.Flags = data:GetFlags()
	
	if self.Flags == 0 then
		self.Forward = (self.EndPos-self.StartPos):GetNormal()
		self.Angles = self.Forward:Angle()
		self.Distance = self.EndPos:Distance(self.StartPos)
		self:SetAngles(self.Angles)
		self.Color = Color(60, 50, 255, 255)
	else
		self.Color = HSVToColor(data:GetColor()*1.4, 1, 1)
	end
	
	self:SetPos(self.StartPos)
	
	if cvars.Bool("ut2k4_lighting") then
		local dynlight = DynamicLight(data:GetEntity())
		dynlight.Pos = self.EndPos
		dynlight.Size = 90
		dynlight.Decay = 90
		dynlight.R = self.Color.r
		dynlight.G = self.Color.g
		dynlight.B = self.Color.b
		dynlight.Brightness = 4
		dynlight.DieTime = CurTime()+.4
	end
end

function EFFECT:Think()
	self.Refract = self.Refract + FrameTime()
	--self.Size = self.Refract*(10) - 10
	if self.Refract >= 1.5 then return false end
	
	return true
end

function EFFECT:Render()
	local col = -self.Refract * 2
	
	if self.Flags == 0 then
		--self:SetModelScale(self.Size, 0)
		self:SetColor(Color(255*col,255*col,255*col,col))
		
		render.SetMaterial(self.EndMat);
		render.DrawSprite( self.StartPos, 20, 20, Color(col,col,col,255*col) )
		render.SetMaterial(self.BeamMat);
		render.DrawBeam( self.StartPos, self.EndPos, 10, 0, 1, Color(col,col,col,255*col) )
		
		for i = 0, self.Distance / 45 do
			self:SetupBones()
			self:SetPos(self.StartPos + self.Forward*i*45)
			self:DrawModel()
		end
	else
		render.SetMaterial(self.EndMat1);
		render.DrawSprite( self.StartPos, 20, 20, Color(self.Color.r * col, self.Color.g * col, self.Color.b * col, 255*col) )
		render.SetMaterial(self.BeamMat1);
		render.DrawBeam( self.StartPos, self.EndPos, 10, 0, 1, Color(self.Color.r * col, self.Color.g * col, self.Color.b * col, 255) )
	end
end
