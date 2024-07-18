ESX = exports["es_extended"]:getSharedObject()
local pranjepostavke = {
    ime = "",
    kordinate = {pos = vector3(0.0, 0.0, 0.0), heading = 0.0},
    prop = "",
    provizija = "",
    webhook = "",
    blip = "false",
    blipName = "MoneyWash",
    blipColor = "1",
    blipSprite = "431"
}

Citizen.CreateThread(function()
    Wait(200)
    while ESX.GetPlayerData().job == nil do
        Citizen.Wait(10)
    end

    PlayerData = ESX.GetPlayerData()
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
    PlayerData = xPlayer
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
    PlayerData.job = job
end)

Objects = {}
AddEventHandler("onResourceStop", function(res)
  if GetCurrentResourceName() == res then
    for i = 1, #Objects do
      DeleteObject(Objects[i])
    end
  end
end)



RegisterNetEvent("earth:napraviPranjepara", function()
  lib.registerContext({
      id = 'pranjeparicaaa_menic',
      title = 'Moneywash Menu',
      options = {
          {
              title = 'Locations',
              description = 'Current money wash',
              icon = 'fa-solid fa-map-marker-alt',
              onSelect = function()
                  listaPranjapara()
              end
          },
          {
              title = 'Create Moneywash',
              description = 'Create Moneywash',
              icon = 'fa-solid fa-plus',
              onSelect = function()
                  TriggerEvent("earth:createpranje")
              end
          }
      }
  })
  lib.showContext('pranjeparicaaa_menic')
end)

function listaPranjapara()
  ESX.TriggerServerCallback("earth:getajPranjepara", function(ucitano)
      local options = {}
      if ucitano == nil or #ucitano == 0  then
          table.insert(options, {
              title = 'There are no locations set',
              description = 'There are currently no locations set.',
          })
      else
          for k, v in pairs(ucitano) do
            if v.provizija == 0.80 then
                textProvizije = "20"
            else
                textProvizije = v.provizija
            end
              table.insert(options, {
                  title = "Moneywash: " .. v.ime,
                  description = "Prop: " .. v.prop .. "\nTax: " .. textProvizije .. "%\nClick for additional options",
                  onSelect = function()
                    dodatneopcije(v.ime)
                  end,
              })
          end
      end

      lib.registerContext({
          id = 'pranjeparaovo',
          title = 'List of Moneywash',
          options = options
      })
      lib.showContext('pranjeparaovo')
  end)
end


function dodatneopcije(imePranjapara)
  ESX.TriggerServerCallback("earth:getajPranjepara", function(ucitano)
      local options = {}
      if ucitano == nil or #ucitano == 0  then
          table.insert(options, {
            title = 'There are no locations set',
            description = 'There are currently no locations set.',
          })
      else
          for k, v in pairs(ucitano) do
            if v.ime == imePranjapara then
                table.insert(options, {
                    title = "Delete: " .. imePranjapara,
                    onSelect = function()
                        obrisiPranje(imePranjapara)
                    end,
                })
                table.insert(options, {
                    title = "Teleport to location: " .. imePranjapara,
                    onSelect = function()
                        ESX.TriggerServerCallback("earth:teleportPranjepara", function(teleporter)
                            print(imePranjapara)
                        end, imePranjapara)
                    end,
                })
                --[[
                table.insert(options, {
                    title = "Promjeni provoziju",
                    onSelect = function()
                        promjeniProviziju(imePranjapara)
                    end,
                })
                table.insert(options, {
                    title = "Promijeni kordinate",
                    onSelect = function()
                        promijeniKordinatePranja(imePranjapara)
                    end,
                })]]
            end
        end
     end

      lib.registerContext({
          id = 'pranjeparaopcije',
          title = 'Moneywash Menu',
          options = options
      })
      lib.showContext('pranjeparaopcije')
  end)
end

function promjeniProviziju(imeNjega)
    ESX.TriggerServerCallback("earth:getajPranjepara", function(ucitano)
        for k,v in pairs(ucitano) do
            if v.ime == imeNjega then
                if v.provizija == 0.8 then
                    kurcinaMoja = 20
                else
                    kurcinaMoja = v.provizija
                end
                local input = lib.inputDialog('Change Tax', {
                    {type = 'number', label = "Change Tax", default = kurcinaMoja, required = true}
                })
                if not input then return end
                if input[1] == 20 then
                    stavigaUnutra = 0.80
                else
                    stavigaUnutra = input[1]
                end
                ESX.TriggerServerCallback("earth:editProvizija", function(ucitano)
                    print(ucitano)
                end, imeNjega, input[1])
            end
        end
    end)
end

RegisterNetEvent("earth:createpranje", function()
    local playerPed = PlayerPedId()
    local pos = GetOffsetFromEntityInWorldCoords(playerPed, 0.0, 1.0, 0.0)
    local heading = GetEntityHeading(playerPed)
    local input = lib.inputDialog('Moneywash', {
        {type = 'input', label = 'Name', description = 'Enter what you want the location to be called', required = true},
        {type = 'select', label = 'Prop', description = 'Select prop', required = true,
        options={
          {
            label = "xm_prop_rsply_crate04b",
            value = "xm_prop_rsply_crate04b",
          },
          {
            label = "prop_washer_01",
            value = "prop_washer_01",
          },
        } },
        --[[
        {type = 'select', label = 'Animacije', description = 'Odabirite animaciju', required = true,
        options={
          {
            label = "idle_dryermoney",
            value = "anim@scripted@cbr1@ig1_washmach_grab_cash@heeled@ ",
          },
        } },]]
        {type = 'number', label = 'Tax', description = 'Enter the percentage you want it to take', required = true},
        {type = 'input', label = 'Webhook', description = 'Enter the webhook where you want the logs to come from', required = true},
        {type = 'checkbox', label = 'Blip'},
    })
    if not input then return end
    if input[3] == 20 then
        stavigaUnutra = 0.80
    else
        stavigaUnutra = input[3]
    end
    if input[6] == true then
        local blipInput = lib.inputDialog('Blip Opcije', {
            {type = 'input', label = 'Sprite(id)', description = 'Enter sprite id', default = "431", required = true},
            {type = 'input', label = 'Color', description = 'Enter color id', default = "1", required = true},
            {type = 'input', label = 'Blip Name', description = 'Enter name blip on map', default = "Moneywash", required = true},
        })
        if not blipInput then return end
        local spriteId = tonumber(blipInput[1])
        local color = tonumber(blipInput[2])

        if not spriteId or not color then
            print("The entered values are not correct.")
            return
        end

        local blip = AddBlipForCoord(pos.x, pos.y, pos.z)
        SetBlipSprite(blip, spriteId)
        SetBlipColour(blip, color)
        BeginTextCommandSetBlipName("STRING")
        SetBlipScale(blip, 0.9)
        AddTextComponentString(blipInput[3])
        EndTextCommandSetBlipName(blip)
        pranjepostavke.blipName = blipInput[3]
        pranjepostavke.blipColor = blipInput[2]
        pranjepostavke.blipSprite = blipInput[1]
    end
    -- Sacuvaj pranjepara opcije
    pranjepostavke.ime = input[1]
    pranjepostavke.prop = input[2]
    pranjepostavke.provizija = stavigaUnutra
    pranjepostavke.kordinate = vector3(pos.x, pos.y, pos.z -1)
    pranjepostavke.webhook = input[4]
    pranjepostavke.blip = input[5]
    StvoriPranjeparaModel(pranjepostavke.ime .. "_pranjepara", pranjepostavke.kordinate, pranjepostavke.heading, pranjepostavke.prop)
    ESX.TriggerServerCallback("earth:sacuvajPranje", function()
    end, pranjepostavke)
    exports.qtarget:RemoveZone("Pranjepara - " .. pranjepostavke.ime)
    exports.qtarget:AddBoxZone("Pranjepara - " .. pranjepostavke.ime, pranjepostavke.kordinate, 3.4, 3.4, {
        name = "Pranjepara - " .. pranjepostavke.ime,
        heading = pranjepostavke.heading,
        debugPoly = false,
        minZ =  pranjepostavke.kordinate.z - 2,
        maxZ =  pranjepostavke.kordinate.z,
        }, 
        {
        options = {
        {
            action = function()
                operiPare(pranjepostavke.ime)
            end,
            icon = "fas fa-circle",
            label = "Moneywash",
        },
        },
        distance = 2.0
    })
end)

function StvoriPranjeparaModel(pedName, pos, heading, pedType)
    pranjePropSpawn = CreateObject(pedType, vector3(pos.x, pos.y, pos.z -1), false, true)
    SetEntityHeading(pranjePropSpawn, heading)
    FreezeEntityPosition(pranjePropSpawn, true) 
    SetEntityInvincible(pranjePropSpawn, true)
    PlaceObjectOnGroundProperly(pranjePropSpawn)
    table.insert(Objects, pranjePropSpawn)
    SetModelAsNoLongerNeeded(pedType)
end

Citizen.CreateThread(function()
  Wait(200)
  ESX.TriggerServerCallback("earth:getajPranjepara", function(ucitano)
      for k,v in pairs(ucitano) do
          StvoriPranjeparaModel(v.ime .. "_pranjepara", v.kordinate, v.heading, v.prop)
          if v.blip == true then
            local spriteId = tonumber(v.blipSprite)
            local color = tonumber(v.blipColor)

            local blip = AddBlipForCoord(v.kordinate.x, v.kordinate.y, v.kordinate.z)
            SetBlipSprite(blip, spriteId)
            SetBlipColour(blip, color)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString(v.blipName)
            SetBlipScale(blip, 0.9)
            EndTextCommandSetBlipName(blip)
          end
          exports.qtarget:RemoveZone("Pranjepara - " .. v.ime)
          exports.qtarget:AddBoxZone("Pranjepara - " .. v.ime, v.kordinate, 3.4, 3.4, {
              name = "Pranjepara - " .. v.ime,
              heading = v.heading,
              debugPoly = false,
              minZ =  v.kordinate.z - 2,
              maxZ =  v.kordinate.z,
              }, 
              {
              options = {
              {
                  action = function()
                    operiPare(v.ime)
                  end,
                  icon = "fas fa-circle",
                  label = "Moneywash",
              },
              },
              distance = 3.0
          })
      end
  end)
end)

function operiPare(imeNjega)
    ESX.TriggerServerCallback("earth:getajPranjepara", function(ucitano)
        for k,v in pairs(ucitano) do
            if v.ime == imeNjega then
                if v.provizija == 0.80 then
                    textProvizije = "20"
                else
                    textProvizije = v.provizija
                end
                local input = lib.inputDialog('Moneywash', {
                    {type = 'number', label = 'Amount of Money - Tax: ' ..textProvizije .. "%", description = 'Enter the amount you want to wash', required = true}
                })
                if not input then return end
                ESX.TriggerServerCallback("earth:pranjeNovca", function(ucitano)
                 --   print(ucitano)
                end, input[1], v.provizija, imeNjega)
            end
        end
    end)
end

function obrisiPranje(pranjeIme)
  ESX.TriggerServerCallback("earth:obrisiPranje", function(success)
      if success then
          for i = 1, #Objects do
              DeleteObject(Objects[i])
          end
          ESX.TriggerServerCallback("earth:getajPranjepara", function(ucitano)
              for k,v in pairs(ucitano) do
                StvoriPranjeparaModel(v.ime .. "_pranjepara", v.kordinate, v.heading, v.prop)
              end
          end)
      end
  end, pranjeIme)
end
--[[
function promijeniKordinatePranja(imeNjega)
    local playerPed = PlayerPedId()
    local pos = GetEntityCoords(playerPed)
    local heading = GetEntityHeading(playerPed)
    print("[earth]: Restartujem sve propove...")
    for i = 1, #Objects do
        DeleteObject(Objects[i])
    end
    Wait(3000)
    ESX.TriggerServerCallback("earth:promjeniLokacijuPranja", function(promjenanjegova)
        print(imeNjega)
    end, imeNjega, pos.x, pos.y, pos.z, heading)
    ESX.TriggerServerCallback("earth:getajPranjepara", function(ucitano)
        for k,v in pairs(ucitano) do
            StvoriPranjeparaModel(v.ime .. "_pranjepara", v.kordinate, v.heading, v.prop)
            exports.qtarget:RemoveZone("Pranjepara - " .. pranjepostavke.ime)
            exports.qtarget:AddBoxZone("Pranjepara - " .. pranjepostavke.ime, v.kordinate, 3.4, 3.4, {
                name = "Pranjepara - " .. pranjepostavke.ime,
                heading = pranjepostavke.heading,
                debugPoly = false,
                minZ =  pos.z- 2,
                maxZ =  pos.z,
                }, 
                {
                options = {
                {
                    action = function()
                        operiPare(v.ime)
                    end,
                    icon = "fas fa-circle",
                    label = "Moneywash",
                },
                },
                distance = 2.0
            })
        end
    end)
end]]

