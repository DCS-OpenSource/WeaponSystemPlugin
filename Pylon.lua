local Pylon = {}
Pylon.__index = Pylon

function Pylon:new(parent, index, weaponType, armed)
    local self = setmetatable({}, Pylon)
    self.parent = parent          -- reference to the WeaponSystem instance
    self.index = index
    self.weaponType = weaponType or "Unknown"
    self.armed = armed or false
    return self
end


function Pylon:launch()
    if self.armed then
        local stationInfo = self:getStationInfo()
        if stationInfo.weapon.level3 == wsType_Rocket then
            self.parent.device:launch_station(self.index - 1)
            return true
        end
    end
end

function Pylon:setArmed(armed)
    self.armed = armed
end

function Pylon:getStationInfo()
    return self.parent.device:get_station_info(self.index - 1)
end


function Pylon:jettison()
    print_message_to_user("Jettisoning pylon " .. self.index)
end

function Pylon:isArmed()
    return self.armed
end

return Pylon
