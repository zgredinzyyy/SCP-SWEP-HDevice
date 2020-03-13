local exceptionButtonID = exceptionButtonID or
{
	-- [2346] = true,
	-- [3510] = true,
	-- [3762] = true,
	-- [1781] = true,
	-- [1783] = true,
}

if not file.Exists( "guth_scp", "DATA" ) then file.CreateDir( "guth_scp" ) end

if file.Exists( "guth_scp", "DATA") and not file.Exists("hdevice_blocked_buttons.txt", "DATA/guth_scp")then
	exceptionButtonID[game.GetMap()] = {}
	file.Write( "guth_scp/hdevice_blocked_buttons.txt", util.TableToJSON( exceptionButtonID ) )
end

if SERVER then
    concommand.Add( "hdevice_block_button", function( ply )
		if not ply:IsValid() or not ply:IsSuperAdmin() then return end

		local ent = ply:GetEyeTrace().Entity
		if not IsValid( ent ) or not GuthSCP.keycardAvailableClass[ ent:GetClass() ] then 
			ply:PrintMessage( HUD_PRINTCONSOLE, "HDevice - Invalid entity selected!" )
			return
		end

		if not exceptionButtonID[game.GetMap()] then exceptionButtonID[game.GetMap()] = {} end
		exceptionButtonID[game.GetMap()][ent:MapCreationID()] = true

		if not file.Exists( "guth_scp", "DATA" ) then file.CreateDir( "guth_scp" ) end
        file.Write( "guth_scp/hdevice_blocked_buttons.txt", util.TableToJSON( exceptionButtonID ) )
        
        GuthSCP.exceptionButtonID = exceptionButtonID

		ply:PrintMessage( HUD_PRINTCONSOLE, "HDevice - Button ID has been saved" )
    end )

    concommand.Add( "hdevice_unblock_button", function( ply )
		if not ply:IsValid() or not ply:IsSuperAdmin() then return end

		local ent = ply:GetEyeTrace().Entity
		if not IsValid( ent ) or not GuthSCP.keycardAvailableClass[ ent:GetClass() ] then 
			ply:PrintMessage( HUD_PRINTCONSOLE, "HDevice - Invalid entity selected!" )
			return
		end

		if not exceptionButtonID[game.GetMap()] then exceptionButtonID[game.GetMap()] = {} end
		exceptionButtonID[game.GetMap()][ent:MapCreationID()] = nil

		if not file.Exists( "guth_scp", "DATA" ) then file.CreateDir( "guth_scp" ) end
		file.Write( "guth_scp/hdevice_blocked_buttons.txt", util.TableToJSON( exceptionButtonID ) )

        GuthSCP.exceptionButtonID = exceptionButtonID

		ply:PrintMessage( HUD_PRINTCONSOLE, "HDevice - Button ID has been saved" )
	end )
end

hook.Add( "PlayerInitialSpawn", "HDevice:GetIDs", function()
	
	if not GuthSCP then
		print("HDevice - Guthen Keycard System not found, HDevice won't work without it.")
		return
	end	
	
	if file.Exists( "guth_scp/hdevice_blocked_buttons.txt", "DATA" ) then
        local txt = file.Read( "guth_scp/hdevice_blocked_buttons.txt", "DATA" )
        exceptionButtonID = util.JSONToTable( txt )
        GuthSCP.exceptionButtonID = exceptionButtonID
		print( "HDevice - Buttons IDs loaded!" )
	end

	hook.Remove( "PlayerInitialSpawn", "HDevice:GetIDs" )
end )
