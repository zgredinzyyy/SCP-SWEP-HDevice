SWEP.PrintName			    = "SCP - Hacking Device"
SWEP.Category				= "GuthSCP"
SWEP.Author			        = "Guthen, zgredinzyyy"
SWEP.Instructions		    = "Press Left Mouse Button to hack nearest doors."

SWEP.Spawnable              = true

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo		    = "none"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo		    = "none"

SWEP.Weight	                = 5
SWEP.AutoSwitchTo		    = false
SWEP.AutoSwitchFrom		    = false

SWEP.Slot			        = 1
SWEP.SlotPos			    = 2
SWEP.DrawAmmo			    = false
SWEP.DrawCrosshair		    = true

SWEP.ViewModel			    = "models/weapons/v_grenade.mdl"
SWEP.WorldModel			    = "models/weapons/v_grenade.mdl"

SWEP.HoldType = "slam"

SWEP.UseHands = false
SWEP.ShowViewModel = false
SWEP.ShowWorldModel = false

SWEP.GuthSCPLVL       		= 0 -- Starting with 0 so player can't open doors without hacking and let keycard system asociate this SWEP with keycard

local hackingdevice_hack_time = CreateConVar("hdevice_hack_time", "5", {FCVAR_ARCHIVE}, "Amount of seconds needed for hacking device to open certain door.")
local hackingdevice_hack_max = CreateConVar("hdevice_hack_max", "5", {FCVAR_ARCHIVE}, "Highest level that the device can crack.")

function SWEP:Success(ent)
	self.isHacking = false
	ent:Use(self.Owner,ent,4,1) -- Opening Doors
	self.Owner:setBottomMessage("Hacking Done!")
end

function SWEP:Failure(fail) -- True if failed by canceling hacking process, false if hacking is limited
	self.isHacking = false
	if fail == 1 then
		self.Owner:setBottomMessage("Hacking FAILED!")
	elseif fail == 2 then
		self.Owner:setBottomMessage("Hacking limited to LVL " .. hackingdevice_hack_max:GetInt() .. " Keycard")
	else
		self.Owner:setBottomMessage("Can't hack this!")
	end
end

function SWEP:PrimaryAttack()
    local tr = self.Owner:GetEyeTrace()
	local ent = tr.Entity
	local trLVL = ent:GetNWInt( "GuthSCP:LVL", 0 )
	if IsValid(tr.Entity) and tr.HitPos:Distance(self.Owner:GetShootPos()) < 50 and trLVL <= hackingdevice_hack_max:GetInt() and not GuthSCP.exceptionButtonID[game.GetMap()][ent:MapCreationID()] then
		self.Owner:setBottomMessage("Hacking Started!")
        self.isHacking = true
        self.startHack = CurTime()
		self.endHack = CurTime() + ent:GetNWInt( "GuthSCP:LVL", 0 )*hackingdevice_hack_time:GetInt()
		self.Weapon:SetNextPrimaryFire(CurTime()+3)
		print()
	elseif GuthSCP.exceptionButtonID[game.GetMap()][ent:MapCreationID()] then
		self:Failure(3)
	elseif IsValid(tr.Entity) and tr.HitPos:Distance(self.Owner:GetShootPos()) < 50 and trLVL ~= 0 and trLVL > hackingdevice_hack_max:GetInt() then
		self:Failure(2)
	end
end

function SWEP:SecondaryAttack() end

function SWEP:Think()
    local tr = self.Owner:GetEyeTrace()
	local ent = tr.Entity

    if not self.startHack then
		self.startHack = 0
		self.endHack = 0
	end

	if self.isHacking and IsValid(self.Owner) then
		local tr = self.Owner:GetEyeTrace()	
		if not IsValid(tr.Entity) or tr.HitPos:Distance(self.Owner:GetShootPos()) > 50 or not GuthSCP.keycardAvailableClass[ ent:GetClass() ] then
			self:Failure(1)
		elseif self.endHack <= CurTime() then
			self:Success(tr.Entity)
		end
	else
		self.startHack = 0
		self.endHack = 0
	end
	
	self:NextThink(CurTime())
	return true
end

function SWEP:DrawHUD()
    local ply = self.Owner
    if not IsValid( ply ) or not ply:Alive() then return end

	local trg = ply:GetEyeTrace().Entity
	local tr = self.Owner:GetEyeTrace()
    if not IsValid( trg ) then return end
	if not GuthSCP.keycardAvailableClass[ trg:GetClass() ] then return end
	
    if trg:GetNWInt( "GuthSCP:LVL", 0 ) and tr.HitPos:Distance(self.Owner:GetShootPos()) < 50 then
		draw.SimpleText( "Keycard LVL Required: " .. trg:GetNWInt( "GuthSCP:LVL", 0 ), "ChatFont", ScrW()/2+50, ScrH()/2, Color( 255, 255, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
		if trg:GetNWInt( "GuthSCP:LVL", 0 ) ~= 0 then
			draw.SimpleText( "Estimated Hack Time: " .. trg:GetNWInt( "GuthSCP:LVL", 0 )*hackingdevice_hack_time:GetInt(), "ChatFont", ScrW()/2+50, ScrH()/2+15, Color( 255, 255, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
		end
	end
end