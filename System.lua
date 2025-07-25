dofile(LockOn_Options.common_script_path.."../../../Database/wsTypes.lua")

local WeaponSystem = {}
WeaponSystem.__index = WeaponSystem

package.path = package.path..";"..LockOn_Options.script_path.."WeaponSystemPlugin/?.lua"
local Pylon = require("Pylon")

local rocketSalvoTimer = -1
local rocketsFiredThisSalvo = 0

--- This is the WeaponSystem class that manages multiple pylons and their operations.
--- @param device table The device that this weapon system is associated with. (parse it GetSelf())
--- @return self table WeaponSystem object
function WeaponSystem:new(device)
    local self = setmetatable({}, WeaponSystem)
    self.device = device
    self.pylons = {}
    self.rocketSalvoQuantity = 1 -- How many rockets should be fired per press
    self.rocketSalvoInterval = 0
    self.weaponTypes = {
        ["ROCKETS"]     = wsType_Rocket,
        ["BOMBS"]       = wsType_Bomb,
        ["MISSILES"]    = wsType_Missile,
        ["SHELL"]       = wsType_Shell
    }
    return self
end

--- Adds a new pylon to the weapon system.
--- @param index number The index of the pylon (1-based).
--- @param weaponType table The type of weapon this pylon will carry. {"ROCKETS", "BOMBS", "MISSILES", "SHELL"}.
function WeaponSystem:addPylon(index, weaponType, armed)
    local pylon = Pylon:new(self, index, weaponType, armed)
    table.insert(self.pylons, pylon)
end


--- Sets the armed status of a specific pylon.
--- @param index number The index of the pylon (1-based).
--- @param armed boolean The armed status to set.
function WeaponSystem:armPylon(index, armed)
    if self.pylons[index] then
        self.pylons[index]:setArmed(armed)
    end
end

--- Launches the weapon from the currently selected pylon.
--- @param index number|nil The index of the pylon to launch from (1-based). If nil, it will launch from all armed pylons.
--- @return nil
function WeaponSystem:launch(index)
    if not index then
        for i, pylon in ipairs(self.pylons) do
            pylon:launch()
        end
    else
        self.pylons[index]:launch()
    end
end


-- TODO, if you switch armed pylons mid salvo, it fires rockets in the new pylon (fix)
function WeaponSystem:update()
    if rocketSalvoTimer >= 0 then
        rocketSalvoTimer = rocketSalvoTimer + update_rate

        if rocketSalvoTimer >= self.rocketSalvoInterval then
            rocketSalvoTimer = 0
            rocketsFiredThisSalvo = rocketsFiredThisSalvo + 1

            for i, pylon in ipairs(self.pylons) do
                if pylon.armed and pylon:getStationInfo().weapon.level3 == wsType_Rocket and pylon:getStationInfo().count > 0 then
                    pylon:launch()
                end
            end
        end
        if (rocketsFiredThisSalvo >= self.rocketSalvoQuantity) then
            rocketSalvoTimer = -1
            rocketsFiredThisSalvo = 0
        end
    end
end


--- Function to start the rocket salvo firing process.
function WeaponSystem:fireRocketSalvo()
    if rocketSalvoTimer == -1 then -- if not already firing a salvo
        rocketSalvoTimer = 0 -- start the timer for the salvo in update
    end
end


--- Function to setup rocket salvo math
--- @param interval number The time interval between each rocket in the salvo. (in seconds)
function WeaponSystem:setRocketSalvoInterval(interval)
    self.rocketSalvoInterval = interval
end


--- Function to set the number of rockets to fire in a salvo.
--- @param quantity number The number of rockets to fire in a salvo.
function WeaponSystem:setRocketSalvoQuantity(quantity)
    self.rocketSalvoQuantity = quantity
end


--- Function to return the list of pylon objects
--- @return table pylons list of Pylon objects managed by this WeaponSystem.
function WeaponSystem:getPylons()
    return self.pylons
end


--- Function to jettison a specific pylon.
--- @param index number The index of the pylon to jettison (1-based).
--- @return nil
function WeaponSystem:jettisonPylon(index)
    self.pylons[index]:jettison()
end


--- Function to jettison all pylons.
--- This is an emergency jettison function that removes all pylons.
--- @return nil
function WeaponSystem:emergencyJettison()
    print("Emergency jettison of all pylons")
    for i, pylon in ipairs(self.pylons) do
        if pylon then pylon:jettison() end
        self.pylons[i] = nil
    end
end

return WeaponSystem
