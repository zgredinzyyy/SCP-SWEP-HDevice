local exceptionButtonID = exceptionButtonID or
{
	-- [2346] = true,
	-- [3510] = true,
	-- [3762] = true,
	-- [1781] = true,
	-- [1783] = true,
}

if SERVER then
    concommand.Add( "hdevice_button_block", function( ply )
		if not ply:IsValid() or not ply:IsSuperAdmin() then return end

		local ent = ply:GetEyeTrace().Entity
		if not IsValid( ent ) or not GuthSCP.keycardAvailableClass[ ent:GetClass() ] then return end

		if not exceptionButtonID[game.GetMap()] then exceptionButtonID[game.GetMap()] = {} end
		exceptionButtonID[game.GetMap()][ent:MapCreationID()] = true

		if not file.Exists( "guth_scp", "DATA" ) then file.CreateDir( "guth_scp" ) end
        file.Write( "guth_scp/hdevice_blocked_buttons.txt", util.TableToJSON( exceptionButtonID ) )
        
        GuthSCP.exceptionButtonID = exceptionButtonID

		ply:PrintMessage( HUD_PRINTCONSOLE, "HDevice - Button ID has been saved" )
    end )

    concommand.Add( "hdevice_button_unblock", function( ply )
		if not ply:IsValid() or not ply:IsSuperAdmin() then return end

		local ent = ply:GetEyeTrace().Entity
		if not IsValid( ent ) or not GuthSCP.keycardAvailableClass[ ent:GetClass() ] then return end

		if not exceptionButtonID[game.GetMap()] then exceptionButtonID[game.GetMap()] = {} end
		exceptionButtonID[game.GetMap()][ent:MapCreationID()] = nil

		if not file.Exists( "guth_scp", "DATA" ) then file.CreateDir( "guth_scp" ) end
		file.Write( "guth_scp/hdevice_blocked_buttons.txt", util.TableToJSON( exceptionButtonID ) )

        GuthSCP.exceptionButtonID = exceptionButtonID

		ply:PrintMessage( HUD_PRINTCONSOLE, "HDevice - Button ID has been saved" )
	end )
end

hook.Add( "PlayerInitialSpawn", "HDevice:GetIDs", function()
    if file.Exists( "guth_scp/hdevice_blocked_buttons.txt", "DATA" ) then
        local txt = file.Read( "guth_scp/hdevice_blocked_buttons.txt", "DATA" )
        exceptionButtonID = util.JSONToTable( txt )
        GuthSCP.exceptionButtonID = exceptionButtonID
        print( "HDevice - Button IDs loaded !" )
    end

	hook.Remove( "PlayerInitialSpawn", "HDevice:GetIDs" )
end )
