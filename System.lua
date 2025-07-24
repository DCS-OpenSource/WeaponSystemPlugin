dofile(LockOn_Options.common_script_path.."../../../Database/wsTypes.lua")

local WeaponSystem = {}
WeaponSystem.__index = WeaponSystem

package.path = package.path..";"..LockOn_Options.script_path.."WeaponSystemPlugin/?.lua"
local Pylon = require("Pylon")

--- This is the WeaponSystem class that manages multiple pylons and their operations.
--- @param device table The device that this weapon system is associated with. (parse it GetSelf())
--- @return self table WeaponSystem object
function WeaponSystem:new(device)
    local self = setmetatable({}, WeaponSystem)
    self.device = device
    self.pylons = {}
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

--- Launches the weapon from the currently selected pylon.
--- @return nil
function WeaponSystem:launch()
    for _, pylon in ipairs(self.pylons) do
        pylon:launch()
    end
end

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
