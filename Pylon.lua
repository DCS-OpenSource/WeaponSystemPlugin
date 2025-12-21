local Pylon = {}
Pylon.__index = Pylon

function Pylon:new(parent, index, armed)
    local self = setmetatable({}, Pylon)
    self.parent = parent          -- reference to the WeaponSystem instance
    self.index = index
    self.armed = armed or false
    return self
end


function Pylon:launch()
    if self.armed then
        local stationInfo = self:getStationInfo()
        if stationInfo.weapon.level3 == wsType_Rocket then
            self.parent.device:launch_station(self.index - 1)
            return true
        elseif stationInfo.weapon.level2 == wsType_Shell then
            self.parent.device:launch_station(self.index - 1)
            return true
        elseif stationInfo.weapon.level3 == wsType_Bomb_A then
            self.parent.device:launch_station(self.index - 1)
            return true
        else
            return false
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
    self.parent.device:emergency_jettison(self.index - 1)
end

function Pylon:isArmed()
    return self.armed
end

return Pylon
