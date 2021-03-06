local function ccTrusted(ply, cmd, args)
        if not ply:IsAdmin() then
                ply:PrintMessage(2,  DarkRP.getPhrase("need_admin", "rp_trusted"))
                return
        end
 
        local target = GAMEMODE:FindPlayer(args[1])
 
        if target then
                if target:GetPData("trusted") == "1" then
                        target:SetPData("trusted", "0")
                        GAMEMODE:Notify(target, 2, 4, string.format("You are no longer trusted.", ""))
                else
                        if target:GetPData("trusted") ~= "1" then
                                target:SetPData("trusted", "1")
                                GAMEMODE:Notify(target, 2, 4, string.format("You are now trusted.", ""))
                        end
                end
               
                if ply:EntIndex() == 0 then
                        DB.Log("Console toggled the Trusted rank of "..target:SteamName(), nil, Color(30, 30, 30))
                else
                        DB.Log(ply:Nick().." ("..ply:SteamID()..") toggled the Trusted rank of "..target:SteamName(), nil, Color(30, 30, 30))
                end
        else
                if ply:EntIndex() == 0 then
                        print(DarkRP.getPhrase("could_not_find", "player: "..tostring(args[1])))
                else
                        ply:PrintMessage(2, DarkRP.getPhrase("could_not_find", "player: "..tostring(args[1])))
                end
        end
end
concommand.Add("rp_trusted", ccTrusted)

/*---------------------------------------------------------------------------
Keypad & Scanner
---------------------------------------------------------------------------*/

local function ccTrigger(ply, cmd, args)
    if not ply:IsAdmin() then
        ply:PrintMessage(2,  DarkRP.getPhrase("need_admin", "rp_trigger"))
        return
    end

	local trace = ply:GetEyeTrace()
	local class = trace.Entity:GetClass()

	if class == "scanner" then 
		trace.Entity:TriggerOutput(trace.Entity.ScannerData['InitDelayGranted'], trace.Entity.ScannerData['LengthGranted'], trace.Entity.ScannerData['KeyGranted'], "Access Granted") 
		trace.Entity:EmitSound("bms_objects/doors/retinal_scanner_access_granted01.wav")
	elseif class == "keypad" or class == "keypad_wire" then
		trace.Entity:Process(true)
	elseif class == "gmod_wire_keypad" then
		trace.Entity:SetNetworkedString("keypad_display", "y")
		Wire_TriggerOutput(trace.Entity, "Valid", 1)
		trace.Entity:EmitSound("buttons/button9.wav")

		trace.Entity.CurrentNum = -1
		timer.Create("wire_keypad_"..trace.Entity:EntIndex(), 2, 1, function()
			if IsValid(trace.Entity) then
				trace.Entity:SetNetworkedString("keypad_display", "")
				trace.Entity.CurrentNum = 0
				Wire_TriggerOutput(trace.Entity, "Valid", 0)
			end
		end)
	end
end
concommand.Add("rp_trigger", ccTrigger)


/*---------------------------------------------------------------------------
Doors
---------------------------------------------------------------------------*/

local function ccDoorOwn(ply, cmd, args)
	if ply:EntIndex() == 0 then
		return
	end

	if not ply:HasPriv("rp_commands") then
		ply:PrintMessage(2, DarkRP.getPhrase("need_admin", "rp_own"))
		return
	end

	local trace = ply:GetEyeTrace()

	if not IsValid(trace.Entity) or not trace.Entity:IsOwnable() or ply:EyePos():Distance(trace.Entity:GetPos()) > 200 then
		return
	end

	trace.Entity:Fire("unlock", "", 0)
	trace.Entity:UnOwn()
	trace.Entity:Own(ply)
	DB.Log(ply:Nick().." ("..ply:SteamID()..") force-owned a door with rp_own", nil, Color(30, 30, 30))
end
concommand.Add("rp_own", ccDoorOwn)

local function ccDisguise(ply, cmd, args)
	if ply:IsAdmin() then
		if ply:GetPData("disguised") == "1" then
			ply:SetPData("disguised", "0")
			GAMEMODE:Notify(ply, 2, 4, string.format("You are no longer disguised.", ""))
		else
			if ply:GetPData("disguised") ~= "1" then
				ply:SetPData("disguised", "1")
				GAMEMODE:Notify(ply, 2, 4, string.format("You are now disguised.", ""))
			end
		end
	end
end
concommand.Add("rp_disguise", ccDisguise)
AddChatCommand("/disguise", ccDisguise)

local function ccDisplayEntityName(ply)
	if ply:IsAdmin() then
		trace = ply:GetEyeTrace();
		
		ply:ChatPrint(trace.Entity:GetName() .. " " .. trace.Entity:GetClass() .. " " .. trace.Entity:EntIndex() .. " " .. tostring(trace.Entity:GetPos()))
		
	end
end
concommand.Add("rp_entityname", ccDisplayEntityName)
AddChatCommand("/entityname", ccDisplayEntityName)

local function ccResetMap(ply, cmd, args)
	if ply:IsAdmin() then
		RunConsoleCommand("changelevel", game.GetMap())
	end
end
concommand.Add("alg_resetmap", ccResetMap)

local function AddWhitelistedUser(ply, cmd, args)
	if ply:IsAdmin() and args[1] ~= nil then
		local steamidgiven = tostring(args[1])
		MySQLite.query([[INSERT INTO whitelist(steamid) VALUES(']]..steamidgiven..[[');]])
		DB.Log(ply:Nick().." ("..ply:SteamID()..") added " .. steamidgiven .. " to the whitelist" , nil, Color(30, 30, 30))
	end
end
concommand.Add("rp_addwhitelist", AddWhitelistedUser)

local function RemoveWhitelistedUser(ply, cmd, args)
	if ply:IsAdmin() and args[1] ~= nil then
		local steamidgiven = tostring(args[1])
		MySQLite.query([[DELETE FROM whitelist WHERE steamid=']]..steamidgiven..[[';]])
		DB.Log(ply:Nick().." ("..ply:SteamID()..") removed " .. steamidgiven .. " from the whitelist" , nil, Color(30, 30, 30))
	end
end
concommand.Add("rp_removewhitelist", RemoveWhitelistedUser)

local function ccResetServer(ply, cmd, args)
	if ply:IsSuperAdmin() then
		RunConsoleCommand("killserver")
	end
end
concommand.Add("alg_resetserver", ccResetServer)

local function ccPlaySound(ply, cmd, args)
	if ply:IsAdmin() then
		local sound = args[1] or self.LastSound

		for _, pl in ipairs( player.GetAll() ) do
		pl:SendLua("surface.PlaySound( \"" .. sound .. "\" )")
		end
	end	
end
concommand.Add("rp_playsound", ccPlaySound)

local function ccOpen(ply, cmd, args)
	if ply:EntIndex() == 0 then
		return
	end

	if not ply:HasPriv("rp_commands") then
		ply:PrintMessage(2,  string.format(LANGUAGE.need_admin, "rp_open"))
		return
	end

	local trace = ply:GetEyeTrace()

	if not IsValid(trace.Entity) or not trace.Entity:IsOwnable() or ply:EyePos():Distance(trace.Entity:GetPos()) > 200 then
		return
	end

	trace.Entity:Fire('unlock', '', 0)
	trace.Entity:Fire('open', '', 0)
	DB.Log(ply:SteamName().." ("..ply:SteamID()..") force-opened a door with rp_open", nil, Color(30, 30, 30))
end
concommand.Add("rp_open", ccOpen)

local function ccClose(ply, cmd, args)
	if ply:EntIndex() == 0 then
		return
	end

	if not ply:HasPriv("rp_commands") then
		ply:PrintMessage(2,  string.format(LANGUAGE.need_admin, "rp_close"))
		return
	end

	local trace = ply:GetEyeTrace()

	if not IsValid(trace.Entity) or not trace.Entity:IsOwnable() or ply:EyePos():Distance(trace.Entity:GetPos()) > 200 then
		return
	end

	trace.Entity:Fire('unlock', '', 0)
	trace.Entity:Fire('close', '', 0)
	DB.Log(ply:SteamName().." ("..ply:SteamID()..") force-closed a door with rp_close", nil, Color(30, 30, 30))
end
concommand.Add("rp_close", ccClose)


local function ccDoorUnOwn(ply, cmd, args)
	if ply:EntIndex() == 0 then
		return
	end

	if not ply:HasPriv("rp_commands") then
		ply:PrintMessage(2, DarkRP.getPhrase("need_admin", "rp_unown"))
		return
	end

	local trace = ply:GetEyeTrace()

	if not IsValid(trace.Entity) or not trace.Entity:IsOwnable() or ply:EyePos():Distance(trace.Entity:GetPos()) > 200 then
		return
	end

	trace.Entity:Fire("unlock", "", 0)
	trace.Entity:UnOwn()
	DB.Log(ply:Nick().." ("..ply:SteamID()..") force-unowned a door with rp_unown", nil, Color(30, 30, 30))
end
concommand.Add("rp_unown", ccDoorUnOwn)

local function unownAll(ply, cmd, args)
	if ply:EntIndex() == 0 then
		return
	end

	if not ply:HasPriv("rp_commands") then
		ply:PrintMessage(2, DarkRP.getPhrase("need_admin", "rp_unown"))
		return
	end

	target = GAMEMODE:FindPlayer(args[1])

	if not IsValid(target) then
		ply:PrintMessage(2, DarkRP.getPhrase("could_not_find", "player: "..tostring(args)))
		return
	end
	target:UnownAll()
	DB.Log(ply:Nick().." ("..ply:SteamID()..") force-unowned all doors owned by " .. target:Nick(), nil, Color(30, 30, 30))
end
concommand.Add("rp_unownall", unownAll)

local function ccAddOwner(ply, cmd, args)
	if ply:EntIndex() == 0 then
		return
	end

	if not ply:HasPriv("rp_commands") then
		ply:PrintMessage(2, DarkRP.getPhrase("need_admin", "rp_addowner"))
		return
	end

	local trace = ply:GetEyeTrace()

	if not IsValid(trace.Entity) or not trace.Entity:IsOwnable() or ply:EyePos():Distance(trace.Entity:GetPos()) > 200 then
		return
	end

	target = GAMEMODE:FindPlayer(args[1])

	if target then
		if trace.Entity:IsOwned() then
			if not trace.Entity:OwnedBy(target) and not trace.Entity:AllowedToOwn(target) then
				trace.Entity:AddAllowed(target)
			else
				ply:PrintMessage(2, DarkRP.getPhrase("rp_addowner_already_owns_door", target))
			end
		else
			trace.Entity:Own(target)
		end
	else
		ply:PrintMessage(2, DarkRP.getPhrase("could_not_find", "player: "..tostring(args)))
	end
	DB.Log(ply:Nick().." ("..ply:SteamID()..") force-added a door owner with rp_addowner", nil, Color(30, 30, 30))
end
concommand.Add("rp_addowner", ccAddOwner)

local function ccRemoveOwner(ply, cmd, args)
	if ply:EntIndex() == 0 then
		return
	end

	if not ply:HasPriv("rp_commands") then
		ply:PrintMessage(2,  DarkRP.getPhrase("need_admin", "rp_removeowner"))
		return
	end

	local trace = ply:GetEyeTrace()

	if not IsValid(trace.Entity) or not trace.Entity:IsOwnable() or ply:EyePos():Distance(trace.Entity:GetPos()) > 200 then
		return
	end

	target = GAMEMODE:FindPlayer(args[1])

	if target then
		if trace.Entity:AllowedToOwn(target) then
			trace.Entity:RemoveAllowed(target)
		end

		if trace.Entity:OwnedBy(target) then
			trace.Entity:removeDoorOwner(target)
		end
	else
		ply:PrintMessage(2, DarkRP.getPhrase("could_not_find", "player: "..tostring(args)))
	end
	DB.Log(ply:Nick().." ("..ply:SteamID()..") force-removed a door owner with rp_removeowner", nil, Color(30, 30, 30))
end
concommand.Add("rp_removeowner", ccRemoveOwner)

local function ccLock(ply, cmd, args)
	if ply:EntIndex() == 0 then
		return
	end

	if not ply:HasPriv("rp_commands") then
		ply:PrintMessage(2,  DarkRP.getPhrase("need_admin", "rp_lock"))
		return
	end

	local trace = ply:GetEyeTrace()

	if not IsValid(trace.Entity) or not trace.Entity:IsOwnable() or ply:EyePos():Distance(trace.Entity:GetPos()) > 200 then
		return
	end

	ply:PrintMessage(2, "Locked.")

	trace.Entity:KeysLock()
	MySQLite.query("REPLACE INTO darkrp_door VALUES("..MySQLite.SQLStr(trace.Entity:EntIndex())..", "..MySQLite.SQLStr(string.lower(game.GetMap()))..", "..MySQLite.SQLStr(trace.Entity.DoorData.title or "")..", 1, "..(trace.Entity.DoorData.NonOwnable and 1 or 0)..", "..(trace.Entity.DoorData.NonRammable or 0)..");")
	DB.Log(ply:Nick().." ("..ply:SteamID()..") force-locked a door with rp_lock (locked door is saved)", nil, Color(30, 30, 30))
end
concommand.Add("rp_lock", ccLock)

function ccVents(ply, cmd, args)
	if not ply:HasPriv("rp_commands") then return end
	for k, v in pairs(ents.FindByName("vents")) do
		v:Fire("Toggle","",0)
	end
end
concommand.Add("rp_vents", ccVents)

function ccAlarmToggle(ply, cmd, args)
	if not ply:HasPriv("rp_commands") then return end
	for k, v in pairs(ents.FindByName("alarmbuttons")) do
		v:Fire("Press","",0)
	end
end
concommand.Add("rp_alarm", ccAlarmToggle)

local function ccUnLock(ply, cmd, args)
	if ply:EntIndex() == 0 then
		return
	end

	if not ply:HasPriv("rp_commands") then
		ply:PrintMessage(2,  DarkRP.getPhrase("need_admin", "rp_unlock"))
		return
	end

	local trace = ply:GetEyeTrace()

	if not IsValid(trace.Entity) or not trace.Entity:IsOwnable() or ply:EyePos():Distance(trace.Entity:GetPos()) > 200 then
		return
	end

	ply:PrintMessage(2, "Unlocked.")
	trace.Entity:KeysUnLock()
	MySQLite.query("REPLACE INTO darkrp_door VALUES("..MySQLite.SQLStr(trace.Entity:EntIndex())..", "..MySQLite.SQLStr(string.lower(game.GetMap()))..", "..MySQLite.SQLStr(trace.Entity.DoorData.title or "")..", 0, "..(trace.Entity.DoorData.NonOwnable and 1 or 0)..", "..(trace.Entity.DoorData.NonRammable or 0)..");")
	DB.Log(ply:Nick().." ("..ply:SteamID()..") force-unlocked a door with rp_unlock (ulocked door is saved)", nil, Color(30, 30, 30))
end
concommand.Add("rp_unlock", ccUnLock)

local function ccSetModel(ply, cmd, args)
	if not args[1] then return end
	if ply:EntIndex() ~= 0 and not ply:HasPriv("rp_commands") then
		ply:PrintMessage(2, string.format(LANGUAGE.need_admin, "rp_setmodel"))
		return
	end

	local target = GAMEMODE:FindPlayer(args[1])

	if target then
		target:SetModel( args[2] ) 
		if not target:Alive() then target:Spawn() end

		if ply:EntIndex() == 0 then
			DB.Log("Console changed the model of "..target:SteamName(), nil, Color(0, 255, 255))
		else
			DB.Log(ply:SteamName().." ("..ply:SteamID()..") changed the model of "..target:SteamName(), nil, Color(0, 255, 255))
		end
	else
		if ply:EntIndex() == 0 then
			print(string.format(LANGUAGE.could_not_find, "player: "..tostring(args[1])))
		else
			ply:PrintMessage(2, string.format(LANGUAGE.could_not_find, "player: "..tostring(args[1])))
		end
		return
	end

end
concommand.Add("rp_setmodel", ccSetModel)

local function ToggleOOC(ply, cmd, args)
	if ply:IsAdmin() then
		if toggleooc == 0 then toggleooc = 1
			ply:PrintMessage(2, "OOC chat has been enabled.")
			GAMEMODE:PrintMessageAll(HUD_PRINTTALK , "OOC Chat has been enabled.")
		else
			if toggleooc == 1 then toggleooc = 0
				ply:PrintMessage(2, "OOC chat has been disabled.")
				GAMEMODE:PrintMessageAll(HUD_PRINTTALK , "OOC Chat has been disabled.")
			end
		end	
	end	
end
concommand.Add("rp_toggleooc", ToggleOOC)
AddChatCommand("/toggleooc", ToggleOOC)

local function ToggleBotKicker(ply, cmd, args)
	if ply:IsAdmin() then
		if botkickervar == true then botkickervar = false
			ply:PrintMessage(2, "Disabled bot kicker.")
		else
			if botkickervar == false then botkickervar = true
				ply:PrintMessage(2, "Enabled bot kicker.")
			end
		end	
	end	
end
concommand.Add("rp_togglebotkicker", ToggleBotKicker)
AddChatCommand("/togglebotkicker", ToggleBotKicker)

/*local function DonationReceived(ply, cmd, args)
	if not args[1] or not args[2] then return end
	local name = args[1] 
	local amount = args[2]
	GAMEMODE:PrintMessageAll(HUD_PRINTTALK , "Thank you to " .. name .. " who just donated " .. amount)
end
concommand.Add("rp_donationreceived", DonationReceived)*/

/*---------------------------------------------------------------------------
Messages
---------------------------------------------------------------------------*/
local function ccTell(ply, cmd, args)
	if not args[1] then return end
	if ply:EntIndex() ~= 0 and not ply:HasPriv("rp_commands") then
		ply:PrintMessage(2,  DarkRP.getPhrase("need_admin", "rp_tell"))
		return
	end

	local target = GAMEMODE:FindPlayer(args[1])

	if target then
		local msg = ""

		for n = 2, #args do
			msg = msg .. args[n] .. " "
		end

		umsg.Start("AdminTell", target)
			umsg.String(msg)
		umsg.End()

		if ply:EntIndex() == 0 then
			DB.Log("Console did rp_tell \""..msg .. "\" on "..target:SteamName(), nil, Color(30, 30, 30))
		else
			DB.Log(ply:Nick().." ("..ply:SteamID()..") did rp_tell \""..msg .. "\" on "..target:SteamName(), nil, Color(30, 30, 30))
		end
	else
		if ply:EntIndex() == 0 then
			print(DarkRP.getPhrase("could_not_find", "player: "..tostring(args[1])))
		else
			ply:PrintMessage(2, DarkRP.getPhrase("could_not_find", "player: "..tostring(args[1])))
		end
	end
end
concommand.Add("rp_tell", ccTell)

local function ccTellAll(ply, cmd, args)
	if not args[1] then return end
	if ply:EntIndex() ~= 0 and not ply:HasPriv("rp_commands") then
		ply:PrintMessage(2, DarkRP.getPhrase("need_admin", "rp_tellall"))
		return
	end


	local msg = ""

	for n = 1, #args do
		msg = msg .. args[n] .. " "
	end

	umsg.Start("AdminTell")
		umsg.String(msg)
	umsg.End()

	if ply:EntIndex() == 0 then
		DB.Log("Console did rp_tellall \""..msg .. "\"", nil, Color(30, 30, 30))
	else
		DB.Log(ply:Nick().." ("..ply:SteamID()..") did rp_tellall \""..msg .. "\"", nil, Color(30, 30, 30))
	end

end
concommand.Add("rp_tellall", ccTellAll)

/*---------------------------------------------------------------------------
Misc
---------------------------------------------------------------------------*/
local function ccRemoveLetters(ply, cmd, args)
	if ply:EntIndex() ~= 0 and not ply:HasPriv("rp_commands")then
		ply:PrintMessage(2, DarkRP.getPhrase("need_admin", "rp_removeletters"))
		return
	end

	local target = GAMEMODE:FindPlayer(args[1])

	if target then
		for k, v in pairs(ents.FindByClass("letter")) do
			if v.SID == target.SID then v:Remove() end
		end
	else
		-- Remove ALL letters
		for k, v in pairs(ents.FindByClass("letter")) do
			v:Remove()
		end
	end

	if ply:EntIndex() == 0 then
		DB.Log("Console force-removed all letters", nil, Color(30, 30, 30))
	else
		DB.Log(ply:Nick().." ("..ply:SteamID()..") force-removed all letters", nil, Color(30, 30, 30))
	end
end
concommand.Add("rp_removeletters", ccRemoveLetters)

local function ccArrest(ply, cmd, args)
	if not args[1] then return end
	if ply:EntIndex() ~= 0 and not ply:HasPriv("rp_commands") then
		ply:PrintMessage(2, DarkRP.getPhrase("need_admin", "rp_arrest"))
		return
	end

	if DB.CountJailPos() == 0 then
		if ply:EntIndex() == 0 then
			print(DarkRP.getPhrase("no_jail_pos"))
		else
			ply:PrintMessage(2, DarkRP.getPhrase("no_jail_pos"))
		end
		return
	end

	local target = GAMEMODE:FindPlayer(args[1])
	if target then
		local length = tonumber(args[2])
		if length then
			target:arrest(length, ply)
		else
			target:arrest(nil, ply)
		end

		if ply:EntIndex() == 0 then
			DB.Log("Console force-arrested "..target:SteamName(), nil, Color(0, 255, 255))
		else
			DB.Log(ply:Nick().." ("..ply:SteamID()..") force-arrested "..target:SteamName(), nil, Color(0, 255, 255))
		end
	else
		if ply:EntIndex() == 0 then
			print(DarkRP.getPhrase("could_not_find", "player: "..tostring(args[1])))
		else
			ply:PrintMessage(2, DarkRP.getPhrase("could_not_find", "player: "..tostring(args[1])))
		end
	end

end
concommand.Add("rp_arrest", ccArrest)

local function ccUnarrest(ply, cmd, args)
	if not args[1] then return end
	if ply:EntIndex() ~= 0 and not ply:HasPriv("rp_commands") then
		ply:PrintMessage(2, DarkRP.getPhrase("need_admin", "rp_unarrest"))
		return
	end

	local target = GAMEMODE:FindPlayer(args[1])

	if target then
		target:unArrest(ply)
		if not target:Alive() then target:Spawn() end

		if ply:EntIndex() == 0 then
			DB.Log("Console force-unarrested "..target:SteamName(), nil, Color(0, 255, 255))
		else
			DB.Log(ply:Nick().." ("..ply:SteamID()..") force-unarrested "..target:SteamName(), nil, Color(0, 255, 255))
		end
	else
		if ply:EntIndex() == 0 then
			print(DarkRP.getPhrase("could_not_find", "player: "..tostring(args[1])))
		else
			ply:PrintMessage(2, DarkRP.getPhrase("could_not_find", "player: "..tostring(args[1])))
		end
		return
	end

end
concommand.Add("rp_unarrest", ccUnarrest)

local function ccSetMoney(ply, cmd, args)
	if not tonumber(args[2]) then ply:PrintMessage(HUD_PRINTCONSOLE, "Invalid arguments") return end
	if ply:EntIndex() ~= 0 and not ply:IsSuperAdmin() then
		ply:PrintMessage(2, DarkRP.getPhrase("need_sadmin", "rp_setmoney"))
		return
	end

	local amount = math.floor(tonumber(args[2]))

	if args[3] then
		amount = args[3] == "-" and math.Max(0, target:getDarkRPVar("money") - amount) or target:getDarkRPVar("money") + amount
	end



	local target = GAMEMODE:FindPlayer(args[1])

	if target then
		local nick = ""
		DB.StoreMoney(target, amount)
		target:SetDarkRPVar("money", amount)

		if ply:EntIndex() == 0 then
			print("Set " .. target:Nick() .. "'s money to: " .. GAMEMODE.Config.currency .. amount)
			nick = "Console"
		else
			ply:PrintMessage(2, "Set " .. target:Nick() .. "'s money to: " .. GAMEMODE.Config.currency .. amount)
			nick = ply:Nick()
		end
		target:PrintMessage(2, nick .. " set your money to: " .. GAMEMODE.Config.currency .. amount)
		if ply:EntIndex() == 0 then
			DB.Log("Console set "..target:SteamName().."'s money to "..GAMEMODE.Config.currency..amount, nil, Color(30, 30, 30))
		else
			DB.Log(ply:Nick().." ("..ply:SteamID()..") set "..target:SteamName().."'s money to "..GAMEMODE.Config.currency..amount, nil, Color(30, 30, 30))
		end
	else
		if ply:EntIndex() == 0 then
			print("Could not find player: " .. args[1])
		else
			ply:PrintMessage(2, "Could not find player: " .. args[1])
		end
		return
	end
end
concommand.Add("rp_setmoney", ccSetMoney, function() return {"rp_setmoney   <ply>   <amount>   [+/-]"} end)

local function ccSetSalary(ply, cmd, args)
	if not tonumber(args[2]) then ply:PrintMessage(HUD_PRINTCONSOLE, "Invalid arguments") return end
	if ply:EntIndex() ~= 0 and not ply:IsSuperAdmin() then
		ply:PrintMessage(2, DarkRP.getPhrase("need_sadmin", "rp_setsalary"))
		return
	end

	local amount = math.floor(tonumber(args[2]))

	if amount < 0 then
		if ply:EntIndex() == 0 then
			print(DarkRP.getPhrase("invalid_x", "argument", args[2]))
		else
			ply:PrintMessage(2, DarkRP.getPhrase("invalid_x", "argument", args[2]))
		end
		return
	end

	if amount > 150 then
		if ply:EntIndex() == 0 then
			print(DarkRP.getPhrase("invalid_x", "argument", args[2].." (<150)"))
		else
			ply:PrintMessage(2, DarkRP.getPhrase("invalid_x", "argument", args[2].." (<150)"))
		end
		return
	end

	local target = GAMEMODE:FindPlayer(args[1])

	if target then
		local nick = ""
		DB.StoreSalary(target, amount)
		target:SetSelfDarkRPVar("salary", amount)
		if ply:EntIndex() == 0 then
			print("Set " .. target:Nick() .. "'s Salary to: " .. GAMEMODE.Config.currency .. amount)
			nick = "Console"
		else
			ply:PrintMessage(2, "Set " .. target:Nick() .. "'s Salary to: " .. GAMEMODE.Config.currency .. amount)
			nick = ply:Nick()
		end
		target:PrintMessage(2, nick .. " set your Salary to: " .. GAMEMODE.Config.currency .. amount)
		if ply:EntIndex() == 0 then
			DB.Log("Console set "..target:SteamName().."'s salary to "..GAMEMODE.Config.currency..amount, nil, Color(30, 30, 30))
		else
			DB.Log(ply:Nick().." ("..ply:SteamID()..") set "..target:SteamName().."'s salary to "..GAMEMODE.Config.currency..amount, nil, Color(30, 30, 30))
		end
	else
		if ply:EntIndex() == 0 then
			print(DarkRP.getPhrase("could_not_find", "player: "..tostring(args[1])))
		else
			ply:PrintMessage(2, DarkRP.getPhrase("could_not_find", "player: "..tostring(args[1])))
		end
		return
	end
end
concommand.Add("rp_setsalary", ccSetSalary)

local function ccSENTSPawn(ply, cmd, args)
	if GAMEMODE.Config.adminsents then
		if ply:EntIndex() ~= 0 and not ply:IsAdmin() then
			GAMEMODE:Notify(ply, 1, 2, DarkRP.getPhrase("need_admin", "gm_spawnsent"))
			return
		end
	end
	Spawn_SENT(ply, args[1])
	DB.Log(ply:Nick().." ("..ply:SteamID()..") spawned SENT "..args[1], nil, Color(255, 255, 0))
end
concommand.Add("gm_spawnsent", ccSENTSPawn)

local function ccVehicleSpawn(ply, cmd, args)
	if GAMEMODE.Config.adminvehicles then
		if ply:EntIndex() ~= 0 and not ply:IsAdmin() then
			if not ply:IsUserGroup("vip") then
				GAMEMODE:Notify(ply, 1, 4, "Only VIP users can spawn vehicles.")
				return
			end	
		end
	end
	Spawn_Vehicle(ply, args[1])
	DB.Log(ply:Nick().." ("..ply:SteamID()..") spawned Vehicle "..args[1], nil, Color(255, 255, 0))
end
concommand.Add("gm_spawnvehicle", ccVehicleSpawn)

local function ccNPCSpawn(ply, cmd, args)
	if GAMEMODE.Config.adminnpcs then
		if ply:EntIndex() ~= 0 and not ply:IsAdmin() then
			GAMEMODE:Notify(ply, 1, 2, DarkRP.getPhrase("need_admin", "gm_spawnnpc"))
			return
		end
	end
	Spawn_NPC(ply, args[1])
	DB.Log(ply:Nick().." ("..ply:SteamID()..") spawned NPC "..args[1], nil, Color(255, 255, 0))
end
concommand.Add("gm_spawnnpc", ccNPCSpawn)

local function ccSetRPName(ply, cmd, args)
	if not args[1] then return end
	if ply:EntIndex() ~= 0 and not ply:IsAdmin() then
		ply:PrintMessage(2, DarkRP.getPhrase("need_sadmin", "rp_setname"))
		return
	end

	local target = GAMEMODE:FindPlayer(args[1])

	if not args[2] or string.len(args[2]) < 2 or string.len(args[2]) > 30 then
		if ply:EntIndex() == 0 then
			print(DarkRP.getPhrase("invalid_x", "argument", args[2]))
		else
			ply:PrintMessage(2, DarkRP.getPhrase("invalid_x", "argument", args[2]))
		end
	end

	if target then
		local oldname = target:Nick()
		local nick = ""
		DB.StoreRPName(target, args[2])
		target:SetDarkRPVar("rpname", args[2])
		if ply:EntIndex() == 0 then
			print("Set " .. oldname .. "'s name to: " .. args[2])
			nick = "Console"
		else
			ply:PrintMessage(2, "Set " .. oldname .. "'s name to: " .. args[2])
			nick = ply:Nick()
		end
		target:PrintMessage(2, nick .. " set your name to: " .. args[2])
		if ply:EntIndex() == 0 then
			DB.Log("Console set "..target:SteamName().."'s name to " .. args[2], nil, Color(30, 30, 30))
		else
			DB.Log(ply:Nick().." ("..ply:SteamID()..") set "..target:SteamName().."'s name to " .. args[2], nil, Color(30, 30, 30))
		end
	else
		if ply:EntIndex() == 0 then
			print(DarkRP.getPhrase("could_not_find", "player: "..tostring(args[1])))
		else
			ply:PrintMessage(2, DarkRP.getPhrase("could_not_find", "player: "..tostring(args[1])))
		end
	end
end
concommand.Add("rp_setname", ccSetRPName)

local function ccCancelVote(ply, cmd, args)
	if ply:EntIndex() ~= 0 and not ply:HasPriv("rp_commands") then
		ply:PrintMessage(2, DarkRP.getPhrase("need_admin", "rp_cancelvote"))
		return
	end

	GAMEMODE.vote.DestroyLast()
	if ply:EntIndex() == 0 then
		nick = "Console"
	else
		nick = ply:Nick()
	end

	GAMEMODE:NotifyAll(0, 4, nick .. " canceled the last vote")
end
concommand.Add("rp_cancelvote", ccCancelVote)