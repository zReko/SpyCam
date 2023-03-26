core:module("CorePortalManager")
local alive_g = alive
local ipairs_g = ipairs
Hooks:PostHook(PortalManager, "init", "SpyCameraPortalManagerInit", function(self)
	self.spyCamCount = 0
    self.spyCams = {}
    self.spyCamEnabled = false
end)
function PortalManager:setPortalCams(data,enabled)
    self.spyCams = data
    self.spyCamCount = #data
    self.spyCamEnabled = enabled
end
function PortalManager:check_positions()
	local check_pos = {}
	for _, vp in ipairs_g(managers.viewport:all_really_active_viewports()) do
		local camera = vp:camera()
		if alive_g(camera) and vp:is_rendering_scene("World") then
			check_pos[#check_pos + 1] = camera:position()
            if self.spyCamEnabled and self.spyCamCount > 0 then
                for i, v in ipairs_g(self.spyCams) do
                    check_pos[#check_pos + 1] = v.cam:position()
                end
            end
		end
	end

	return check_pos
end