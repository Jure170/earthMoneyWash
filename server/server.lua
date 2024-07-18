ESX = exports["es_extended"]:getSharedObject()
local pranjepara = {}

Licence = {
    "98f19dc6c18eebb304c942298b4a7706829cde24",
}

function checkIdentfier(identifier)
    for k, v in pairs(Licence) do
        if identifier == v then
            return true
        end
    end
    return false
end

function LoadPranjepara()
    local tablica = LoadResourceFile(GetCurrentResourceName(), "/json/moneywash.json")
    if tablica then
        pranjepara = json.decode(tablica)
    else
        print("^1[earth]:^0 No data")
        pranjepara = {}
    end
end

function SavePranje()
    SaveResourceFile(GetCurrentResourceName(), "/json/moneywash.json", json.encode(pranjepara, {indent = true}), -1)
end

function getajPranje()
    local tablica = LoadResourceFile(GetCurrentResourceName(), "/json/moneywash.json")
    local opcije = {}
    if tablica then
        opcije = json.decode(tablica)
        return opcije
    else
        print("^1[earth]:^0 No data")
        return {}
    end
end

ESX.RegisterServerCallback('earth:getajPranjepara', function(source, cb)
    local pranjeparica = getajPranje()
    cb(pranjeparica)
end)


AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        LoadPranjepara()
        Wait(2000)
        print("^4[earthMoneywash]:^0 Successfully loaded")
    end
end)

ESX.RegisterServerCallback('earth:sacuvajPranje', function(source, cb, datainfo)
    local igrac = ESX.GetPlayerFromId(source)
	table.insert(pranjepara, datainfo)
	SavePranje()
end)

ESX.RegisterServerCallback('earth:obrisiPranje', function(source, callback, name)
    local pranjepara = json.decode(LoadResourceFile(GetCurrentResourceName(), "/json/moneywash.json"))
    for i, pranjeparica in ipairs(pranjepara) do
        if pranjeparica.ime == name then
            table.remove(pranjepara, i)
            SaveResourceFile(GetCurrentResourceName(), "/json/moneywash.json", json.encode(pranjepara, {indent = true}), -1)
            callback(true)
            LoadPranjepara()
            return
        end
    end
    callback(false)
end)

ESX.RegisterServerCallback("earth:teleportPranjepara", function(source, cb, name)
    local pranjepara = json.decode(LoadResourceFile(GetCurrentResourceName(), "/json/moneywash.json"))
    local found = false

    for i, pranjeparica in ipairs(pranjepara) do
        if pranjeparica.ime == name then
            local lokacija = pranjeparica.kordinate
            TriggerClientEvent('earth:teleportPlayer', source, lokacija)
            TriggerClientEvent('esx:showNotification', source, 'You have been teleported to the money laundering location - ' .. name)
            found = true
            break
        end
    end

    cb(found)
end)


ESX.RegisterServerCallback('earth:editProvizija', function(source, cb, name, provizijaNova)
    local src = source
    local pranjepara = json.decode(LoadResourceFile(GetCurrentResourceName(), "/json/moneywash.json"))
    for i, pranjeparica in ipairs(pranjepara) do
        if pranjeparica.ime == name then
            pranjeparica.provizija = provizijaNova
            break
        end
    end
    SaveResourceFile(GetCurrentResourceName(), "/json/moneywash.json", json.encode(pranjepara, {indent = true}), -1)
end)

ESX.RegisterServerCallback('earth:promjeniLokacijuPranja', function(source, cb, name, x, y, z, heading)
    local src = source
    local pranjepara = json.decode(LoadResourceFile(GetCurrentResourceName(), "/json/moneywash.json"))
    for i, pranjeparica in ipairs(pranjepara) do
        if pranjeparica.ime == name then
            pranjeparica.kordinate = { x = x, y = y, z = z }
            pranjeparica.kordinate.heading = heading
            break
        end
    end
    SaveResourceFile(GetCurrentResourceName(), "/json/moneywash.json", json.encode(pranjepara, {indent = true}), -1)
end)

function pranjeLog(source, message, PlayerDetails, boja, imeTogaKretena)
    local pranjepara = json.decode(LoadResourceFile(GetCurrentResourceName(), "/json/moneywash.json"))
    for i, pranjeparica in ipairs(pranjepara) do
        if pranjeparica.ime == imeTogaKretena then
            local connect = {
                {
                    ["color"] = boja,
                    ["title"] = "**PRANJE LOG**",
                    ["description"] = message,
                    ["footer"] = {
                    ["text"] = "earthDevelopement // moneywashLog",
                    },
                    ["fields"] = {
                        {
                            ["name"] = "ID: "..source,
                            ["value"] = PlayerDetails,
                            ["inline"] = true
                        },
                    },
                }
            }
            PerformHttpRequest(pranjeparica.webhook, function(err, text, headers) end, 'POST', json.encode({embeds = connect}), { ['Content-Type'] = 'application/json' })
        end
    end
end

RegisterServerEvent('earth_pranje:sendLog')
AddEventHandler('earth_pranje:sendLog', function(source, amount, clean, imeTogaKretena)
	local time = os.date('%H:%M')
	local ime = GetPlayerName(source)

    if ime == nil then
        ime = "NEPOZNATO"
    end

    local steamid  = "NEPOZNATO"
    local license  = "NEPOZNATO"
    local discord  = "NEPOZNATO"
    local xbl      = "NEPOZNATO"
    local liveid   = "NEPOZNATO"
    local ip       = "NEPOZNATO"

	for k,v in pairs(GetPlayerIdentifiers(source))do			
		if string.sub(v, 1, string.len("steam:")) == "steam:" then
			steamid = v
			--steamURL = "\nhttps://steamcommunity.com/profiles/" ..tonumber(steamid:gsub("steam:", ""),16)..""
		elseif string.sub(v, 1, string.len("license:")) == "license:" then
			license = v
		elseif string.sub(v, 1, string.len("xbl:")) == "xbl:" then
			xbl  = v
		elseif string.sub(v, 1, string.len("ip:")) == "ip:" then
			ip = v
		elseif string.sub(v, 1, string.len("discord:")) == "discord:" then
			discordid = string.sub(v, 9)
			discord = "<@" .. discordid .. ">"
		elseif string.sub(v, 1, string.len("live:")) == "live:" then
			liveid = v
		end
		
	end
	pranjeLog(source, "Player " ..ime.. " has laundered **$" ..amount.. "** and received **$" ..clean.. "**.", 
	"**Name:** " ..ime.. 
	"\n**Steam ID:** " ..steamid:gsub("steam:", "")..  
	" - [LINK](https://steamcommunity.com/profiles/" ..tonumber(steamid:gsub("steam:", ""),16)..
	")\n**License:** " ..license:gsub("license:", "")..
	"\n**xBox Live ID:** " ..xbl..
	"\n**Live ID:** " ..liveid..
	"\n**Discord:** " ..discord..
	"\n**IP:** ||" ..ip:gsub("ip:", "").. "||", "15844367", imeTogaKretena)
end)

ESX.RegisterServerCallback("earth:pranjeNovca", function(source, cb, count, percent, imeTogaKretena)
    local pranjepara = json.decode(LoadResourceFile(GetCurrentResourceName(), "/json/moneywash.json"))
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    
    if count >= 1 and count <= 1000 then
        xPlayer.showNotification("You can only launder from $1000 and above.")
        cb(false)
        return
    end

    if xPlayer then
        for i, pranjeparica in ipairs(pranjepara) do
            if pranjeparica.ime == imeTogaKretena then
                local xItem = xPlayer.getInventoryItem('black_money')
                if xItem.count < count then
                    xPlayer.showNotification("You don't have that much dirty money.")
                elseif xItem.count >= count then
                    local tax = percent
                    local kwota = count * tax
                    local washedTotal = ESX.Math.Round(tonumber(kwota))
                    xPlayer.removeInventoryItem('black_money', count)
                    xPlayer.addMoney(washedTotal)
                    TriggerEvent("earth_pranje:sendLog", _source, count, washedTotal, imeTogaKretena)
                    xPlayer.showNotification("You have laundered " .. count .. " and received " .. washedTotal .. "$.")
                end
            end
        end
    end
    cb(true)
end)


RegisterCommand("moneywash", function(source)
    local admin = ESX.GetPlayerFromId(source)
    if checkIdentfier(admin.identifier) then
        TriggerClientEvent("earth:napraviPranjepara", source)
    else
        admin.showNotification("You don't have permission.")
    end
end)