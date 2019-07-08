local Tunnel = module("vrp","lib/Tunnel")
local Proxy = module("vrp","lib/Proxy")
vRP = Proxy.getInterface("vRP")
-----------------------------------------------------------------------------------------------------------------------------------------
-- VARIAVEIS
-----------------------------------------------------------------------------------------------------------------------------------------
local hour = 0
local minute = 0
local month = ""
local dayOfMonth = 0
local proximity = 10.001
local voice = 2
local sBuffer = {}
local vBuffer = {}
local CintoSeguranca = false
local ExNoCarro = false
-----------------------------------------------------------------------------------------------------------------------------------------
-- DATA E HORA
-----------------------------------------------------------------------------------------------------------------------------------------
function CalculateTimeToDisplay()
	hour = GetClockHours()
	minute = GetClockMinutes()
	if hour <= 9 then
		hour = "0" .. hour
	end
	if minute <= 9 then
		minute = "0" .. minute
	end
end

function CalculateDateToDisplay()
	month = GetClockMonth()
	dayOfMonth = GetClockDayOfMonth()
	if month == 0 then
		month = "January"
	elseif month == 1 then
		month = "February "
	elseif month == 2 then
		month = "March"
	elseif month == 3 then
		month = "April"
	elseif month == 4 then
		month = "May"
	elseif month == 5 then
		month = "June"
	elseif month == 6 then
		month = "July"
	elseif month == 7 then
		month = "August"
	elseif month == 8 then
		month = "September"
	elseif month == 9 then
		month = "October"
	elseif month == 10 then
		month = "November"
	elseif month == 11 then
		month = "December"
	end
end
-----------------------------------------------------------------------------------------------------------------------------------------
-- CSS
-----------------------------------------------------------------------------------------------------------------------------------------
local css = [[
	.div_informacoes {
		bottom: 3%;
		right: 2%;
		position: absolute;
	}
	.voice1 {
		content: url(https://i.imgur.com/qODLlmI.png);
		height: 32px;
		width: 32px;
		float: left;
	}
	.voice2 {
		content: url(https://i.imgur.com/0XjvSVh.png);
		height: 32px;
		width: 32px;
		float: left;
	}
	.voice3 {
		content: url(https://i.imgur.com/WGagrXs.png);
		height: 32px;
		width: 32px;
		float: left;
	}
	.voice4 {
		content: url(https://i.imgur.com/dtLNTOn.png);
		height: 32px;
		width: 32px;
		float: left;
	}
	.texto {
		margin-right: 12px;
		height: 32px;
		font-family: Arial;
		font-size: 13px;
		text-shadow: 1px 1px #000;
		color: rgba(255,255,255,0.5);
		text-align: right;
		line-height: 16px;
		float: left;
	}
	.texto b {
		color: rgba(255,255,255,0.7);
	}
	.div_barraserver {
		content: url(https://i.imgur.com/aT4vpi0.png);
		top: 0;
		right: 0;
		position: absolute;
		width: 217px;
		height: 169px;
	}
]]
-----------------------------------------------------------------------------------------------------------------------------------------
-- SERVER
-----------------------------------------------------------------------------------------------------------------------------------------
local barraserver = false
RegisterCommand("server",function(source,args)
	if barraserver then
		vRP._removeDiv("barraserver")
		barraserver = false
	else
		vRP._setDiv("barraserver",css,"")
		barraserver = true
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- HUD
-----------------------------------------------------------------------------------------------------------------------------------------
AddEventHandler("playerSpawned",function()
	NetworkSetTalkerProximity(proximity)
	vRP._setDiv("informacoes",css,"")
end)

function UpdateOverlay()
	local ped = PlayerPedId()
	local x,y,z = table.unpack(GetEntityCoords(ped,false))
	local street = GetStreetNameFromHashKey(GetStreetNameAtCoord(x,y,z))
	CalculateTimeToDisplay()
	CalculateDateToDisplay()
	NetworkClearVoiceChannel()
	NetworkSetTalkerProximity(proximity)

	vRP._setDivContent("informacoes","<div class=\"texto\">Today is "..month.." "..dayOfMonth.." - "..hour..":"..minute.."<br>You are at <b>"..street.."</b></div><div class=\"voice"..voice.."\"></div>")
end

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1000)
		UpdateOverlay()
	end
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1)
		local ped = PlayerPedId()
		local ui = GetMinimapAnchor()

		local health = GetEntityHealth(ped)-100
		local varSet1 = (ui.width-0.1182)*(health/100)

		local armor = GetPedArmour(ped)
		if armor > 100.0 then armor = 100.0 end
		local varSet2 = (ui.width-0.0735)*(armor/100)

		if IsPedInAnyVehicle(ped) then
			SetRadarZoom(1000)
			DisplayRadar(true)
			local carro = GetVehiclePedIsIn(ped,false)

			if CintoSeguranca then
			end
		else
			CintoSeguranca = false
			DisplayRadar(false)
		end

		drawRct(ui.x,ui.bottom_y-0.017,ui.width,0.015,30,30,30,255)
		drawRct(ui.x+0.002,ui.bottom_y-0.014,ui.width-0.0735,0.009,50,100,50,255)
		drawRct(ui.x+0.002,ui.bottom_y-0.014,varSet1,0.009,80,156,81,255)
		drawRct(ui.x+0.0715,ui.bottom_y-0.014,ui.width-0.0735,0.009,40,90,117,255)
		drawRct(ui.x+0.0715,ui.bottom_y-0.014,varSet2,0.009,66,140,180,255)

		if IsControlJustPressed(1,212) and GetEntityHealth(ped) > 100 then
			if proximity == 3.001 then
				voice = 2
				proximity = 10.001
			elseif proximity == 10.001 then
				voice = 3
				proximity = 25.001
			elseif proximity == 25.001 then
				voice = 4
				proximity = 50.001
			elseif proximity == 50.001 then
				voice = 1
				proximity = 3.001
			end
			UpdateOverlay()
		end
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- CONTAGEM
-----------------------------------------------------------------------------------------------------------------------------------------
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1000)
		if segundos > 0 then
			segundos = segundos - 1
		end
	end
end)
-----------------------------------------------------------------------------------------------------------------------------------------
-- FUNÇÕES
-----------------------------------------------------------------------------------------------------------------------------------------
function drawRct(x,y,width,height,r,g,b,a)
	DrawRect(x+width/2,y+height/2,width,height,r,g,b,a)
end

function drawTxt(x,y,scale,text,r,g,b,a)
	SetTextFont(4)
	SetTextScale(scale,scale)
	SetTextColour(r,g,b,a)
	SetTextOutline()
	SetTextEntry("STRING")
	AddTextComponentString(text)
	DrawText(x,y)
end

function GetMinimapAnchor()
    local safezone = GetSafeZoneSize()
    local safezone_x = 1.0 / 20.0
    local safezone_y = 1.0 / 20.0
    local aspect_ratio = GetAspectRatio(0)
    local res_x, res_y = GetActiveScreenResolution()
    local xscale = 1.0 / res_x
    local yscale = 1.0 / res_y
    local Minimap = {}
    Minimap.width = xscale * (res_x / (4 * aspect_ratio))
    Minimap.height = yscale * (res_y / 5.674)
    Minimap.left_x = xscale * (res_x * (safezone_x * ((math.abs(safezone - 1.0)) * 10)))
    Minimap.bottom_y = 1.0 - yscale * (res_y * (safezone_y * ((math.abs(safezone - 1.0)) * 10)))
    Minimap.right_x = Minimap.left_x + Minimap.width
    Minimap.top_y = Minimap.bottom_y - Minimap.height
    Minimap.x = Minimap.left_x
    Minimap.y = Minimap.top_y
    Minimap.xunit = xscale
    Minimap.yunit = yscale
    return Minimap
end