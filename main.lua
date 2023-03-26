if not SpyCamera then
    SpyCamera = {}
	SpyCamera.mod_path = ModPath
	SpyCamera.save_path = SavePath
    SpyCamera.mod_instance = ModInstance
    SpyCamera.cameras = {}
    SpyCamera.show_cams = true
    local draw_brush_point = Draw:brush(Color(0.5,0,1,0),0)
	SpyCamera.settings = {
		cam_max = 2,
		remove_order = 1,
		far_range = 5500,
		render_mode = 1,
		placement_mode = 1,
		fill_order = 2,
		fov = 95,
		cam_x = 50,
		cam_y = 350,
		cam_w = 500,
		cam_h = 500,
	}
    local render_modes = {
        "deferred_lighting",
        "albedo_visualization",
    }
    SpyCamera.cam_slots = {}
    function SpyCamera:save()
		local file = io.open(self.save_path .. "spycamera_save.txt", "w+")
		if file then
			file:write(json.encode(self.settings))
			file:close()
		end
	end

	function SpyCamera:load()
		local file = io.open(self.save_path .. "spycamera_save.txt", "r")
		if file then
			local data = json.decode(file:read("*all")) or {}
			file:close()
			for k, v in pairs(data) do
				self.settings[k] = v
			end
		end
        self:updateSettingsPos()
	end
    function SpyCamera:setCameraSlot(id, full)
        local res = RenderSettings.resolution
        local cam = self.cameras[id]
        local settings = self.settings
        if not full then
            local slots = self.cam_slots[id]
            cam.vp:set_dimensions(slots.cam_x/res.x,slots.cam_y/res.y,(settings.cam_w/2)/res.x,(settings.cam_h/2)/res.y)
            return
        end
        cam.vp:set_dimensions(settings.cam_x/res.x,settings.cam_y/res.y,settings.cam_w/res.x,settings.cam_h/res.y)
    end
    function SpyCamera:addCamera()
        if managers.player and managers.player:local_player() then
            local player = managers.player:local_player()
            local move = player:movement()
            local from = move:m_head_pos()
            local to = move:m_head_pos() + move:m_head_rot():y() * 1000
            local ray = World:raycast("ray", from, to, "slot_mask", managers.slot:get_mask("trip_mine_placeables"), "ignore_unit", {})
            if ray then
                local vp = Application:create_world_viewport(0, 0, 1, 1)
                local cam = Overlay:create_camera()
                local wall_normal = Rotation(ray.normal, math.UP)
                vp:set_camera(cam)
                cam:set_position(ray.position + wall_normal:y() * 15)
                if self.settings.placement_mode == 1 then
                    cam:set_rotation(Rotation(move:m_head_rot():y() * -1, math.UP))
                else
                    cam:set_rotation(wall_normal)
                end
                cam:set_fov(self.settings.fov)
                cam:set_far_range(self.settings.far_range)
                cam:set_near_range(20)
                cam:set_aspect_ratio(1)
                cam:set_width_multiplier(1)
                local effect_name = render_modes[self.settings.render_mode or 1]
                local hdr_effect_interface = vp:get_post_processor_effect("World", Idstring("hdr_post_processor"))
                local bloom_effect_interface = vp:get_post_processor_effect("World", Idstring("bloom_combine_post_processor"))
                if hdr_effect_interface then
                    hdr_effect_interface:set_visibility(true)
                end
                if bloom_effect_interface then
                    bloom_effect_interface:set_visibility(true)
                end
                vp:set_post_processor_effect("World", Idstring("deferred"), Idstring(effect_name)):set_visibility(true)
                local replaced = false
                local data = {vp = vp, cam = cam, pos = ray.position, normal = wall_normal}
                for i, v in pairs(self.cameras) do
                    local distance = mvector3.distance(v.pos, ray.position)
                    if distance <= 20 then
                        self.cameras[i] = data
                        replaced = true
                        break
                    end
                end
                if not replaced then
                    table.insert(self.cameras,1,data)
                end
                if #self.cameras > self.settings.cam_max then
                    self:removeCam(self.settings.cam_max+1)
                end
                if #self.cameras > 1 then
                    for i, v in pairs(self.cameras) do
                        self:setCameraSlot(i, false)
                    end
                else
                    self:setCameraSlot(1, true)
                end
                managers.portal:setPortalCams(self.cameras,self.show_cams)
            end
        end
    end
    function SpyCamera:removeCam(id)
        local data = self.cameras[id]
        if data.vp then
            Application:destroy_viewport(data.vp)
        end
        if data.cam then
            Overlay:delete_camera(data.cam)
        end
        table.remove(self.cameras,id)
    end
    function SpyCamera:updateSettingsCam()
        for i, v in pairs(self.cameras) do
            v.cam:set_fov(self.settings.fov)
            v.cam:set_far_range(self.settings.far_range)
            local effect_name = render_modes[self.settings.render_mode or 1]
            local vp = v.vp
            local hdr_effect_interface = vp:get_post_processor_effect("World", Idstring("hdr_post_processor"))
            local bloom_effect_interface = vp:get_post_processor_effect("World", Idstring("bloom_combine_post_processor"))
            if hdr_effect_interface then
                hdr_effect_interface:set_visibility(true)
            end
            if bloom_effect_interface then
                bloom_effect_interface:set_visibility(true)
            end
            vp:set_post_processor_effect("World", Idstring("deferred"), Idstring(effect_name)):set_visibility(true)
        end
    end
    function SpyCamera:updateSettingsPos()
        local x = self.settings.cam_x
        local y = self.settings.cam_y
        local w = self.settings.cam_w
        local h = self.settings.cam_h
        if self.settings.fill_order == 1 then
            self.cam_slots = {
                {cam_x = x, cam_y = y},
                {cam_x = x + w/2, cam_y = y},
                {cam_x = x, cam_y = y + h/2},
                {cam_x = x + w/2, cam_y = y + h/2},
            }
        else
            self.cam_slots = {
                {cam_x = x, cam_y = y},
                {cam_x = x, cam_y = y + h/2},
                {cam_x = x + w/2, cam_y = y},
                {cam_x = x + w/2, cam_y = y + h/2},
            }
        end
        if #self.cameras > self.settings.cam_max then
            self:removeCam(self.settings.cam_max+1)
            managers.portal:setPortalCams(self.cameras,self.show_cams)
        end
        if #self.cameras > 1 then
            for i, v in pairs(self.cameras) do
                self:setCameraSlot(i, false)
            end
        elseif #self.cameras > 0 then
            self:setCameraSlot(1, true)
        end
    end
    function SpyCamera:render()
        if not self.show_cams then
            return
        end
        for i, v in pairs(self.cameras) do
            Application:render("World", v.vp, nil ,"Underlay", v.vp)
            draw_brush_point:sphere(v.pos,8)
        end
    end
end

if RequiredScript then
	local file_name = SpyCamera.mod_path .. RequiredScript:gsub(".+/(.+)", "lua/%1.lua")
	if io.file_is_readable(file_name) then
		dofile(file_name)
	end
end
