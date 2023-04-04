SpyCamera:load()
local menu_id_main = "SpyCameraMenu"
Hooks:Add("LocalizationManagerPostInit", "LocalizationManagerPostInitSpyCamera", function(loc)
	local custom_language
	for _, mod in pairs(BLT and BLT.Mods:Mods() or {}) do
		if mod:GetName() == "PAYDAY 2 THAI LANGUAGE Mod" and mod:IsEnabled() then
			custom_language = "thai"
			break
		end
	end
	if custom_language then
		loc:load_localization_file(SpyCamera.mod_path .. "loc/" .. custom_language ..".txt")
	elseif PD2KR then
		loc:load_localization_file(SpyCamera.mod_path .. "loc/korean.txt")
	else
		local loaded = false
		if Idstring("english"):key() ~= SystemInfo:language():key() then
			for _, filename in pairs(file.GetFiles(SpyCamera.mod_path .. "loc/") or {}) do
				local str = filename:match("^(.*).txt$")
				if str and Idstring(str) and Idstring(str):key() == SystemInfo:language():key() then
					loc:load_localization_file(SpyCamera.mod_path .. "loc/" .. filename)
					loaded = true
					break
				end
			end
		end
		if not loaded then
			local file = SpyCamera.mod_path .. "loc/" .. BLT.Localization:get_language().language .. ".txt"
			if io.file_is_readable(file) then
				loc:load_localization_file(file)
			end
		end
	end
	loc:load_localization_file(SpyCamera.mod_path .. "loc/english.txt", false)
end)
Hooks:Add("MenuManagerSetupCustomMenus", "MenuManagerSetupCustomMenusSpyCamera", function(menu_manager, nodes)
	MenuHelper:NewMenu(menu_id_main)
end)

Hooks:Add("MenuManagerPopulateCustomMenus", "MenuManagerPopulateCustomMenusSpyCamera", function(menu_manager, nodes)
	MenuCallbackHandler.SpyCameraUpdateSettingsPos = function(self, item)
		SpyCamera.settings[item:name()] = item:value()
		SpyCamera:save()
		SpyCamera:updateSettingsPos()
	end
	MenuCallbackHandler.SpyCameraUpdateSettingsCam = function(self, item)
		SpyCamera.settings[item:name()] = item:value()
		SpyCamera:save()
		SpyCamera:updateSettingsCam()
	end
	MenuHelper:AddMultipleChoice({
		id = "cam_max",
		title = "SpyCam_max_cams_title",
		desc = "SpyCam_max_cams_desc",
		callback = "SpyCameraUpdateSettingsPos",
		value = SpyCamera.settings.cam_max,
		items = {"1","2","3","4"},
		menu_id = menu_id_main,
		priority = 89
	})
	MenuHelper:AddMultipleChoice({
		id = "render_mode",
		title = "SpyCam_render_mode_title",
		callback = "SpyCameraUpdateSettingsCam",
		value = SpyCamera.settings.render_mode,
		items = {"SpyCam_render_mode_1", "SpyCam_render_mode_2"},
		menu_id = menu_id_main,
		priority = 88
	})
	MenuHelper:AddMultipleChoice({
		id = "placement_mode",
		title = "SpyCam_placement_mode_title",
		value = SpyCamera.settings.placement_mode,
		items = {"SpyCam_placement_mode_1", "SpyCam_placement_mode_2"},
		menu_id = menu_id_main,
		priority = 87
	})
	MenuHelper:AddMultipleChoice({
		id = "fill_order",
		title = "SpyCam_fill_order_title",
		desc = "SpyCam_fill_order_desc",
		callback = "SpyCameraUpdateSettingsPos",
		value = SpyCamera.settings.fill_order,
		items = {"SpyCam_fill_order_1", "SpyCam_fill_order_2"},
		menu_id = menu_id_main,
		priority = 86
	})
	MenuHelper:AddMultipleChoice({
		id = "remove_order",
		title = "SpyCam_remove_order_title",
		callback = "SpyCameraUpdateSettingsCam",
		value = SpyCamera.settings.remove_order,
		items = {"SpyCam_remove_order_1", "SpyCam_remove_order_2", "SpyCam_remove_order_3"},
		menu_id = menu_id_main,
		priority = 85
	})
	
	MenuHelper:AddSlider({
		id = "cam_x",
		title = "SpyCam_cam_pos_x_title",
		callback = "SpyCameraUpdateSettingsPos",
		value = SpyCamera.settings.cam_x,
		min = 0,
		max = RenderSettings.resolution.x,
		step = 2,
		show_value = true,
		menu_id = menu_id_main,
		priority = 84
	})
	MenuHelper:AddSlider({
		id = "cam_y",
		title = "SpyCam_cam_pos_y_title",
		callback = "SpyCameraUpdateSettingsPos",
		value = SpyCamera.settings.cam_y,
		min = 0,
		max = RenderSettings.resolution.y,
		step = 2,
		show_value = true,
		menu_id = menu_id_main,
		priority = 83
	})
	MenuHelper:AddSlider({
		id = "cam_w",
		title = "SpyCam_cam_pos_w_title",
		callback = "SpyCameraUpdateSettingsPos",
		value = SpyCamera.settings.cam_w,
		min = 0,
		max = RenderSettings.resolution.x,
		step = 2,
		show_value = true,
		menu_id = menu_id_main,
		priority = 82
	})
	MenuHelper:AddSlider({
		id = "cam_h",
		title = "SpyCam_cam_pos_h_title",
		callback = "SpyCameraUpdateSettingsPos",
		value = SpyCamera.settings.cam_h,
		min = 0,
		max = RenderSettings.resolution.y,
		step = 2,
		show_value = true,
		menu_id = menu_id_main,
		priority = 81
	})

	MenuHelper:AddDivider({
		id = "divider5",
		size = 24,
		menu_id = menu_id_main,
		priority = 80
	})
	MenuHelper:AddSlider({
		id = "far_range",
		title = "SpyCam_cam_far_range_title",
		desc = "SpyCam_cam_far_range_desc",
		callback = "SpyCameraUpdateSettingsCam",
		value = SpyCamera.settings.far_range,
		min = 500,
		max = 20000,
		step = 8,
		show_value = true,
		menu_id = menu_id_main,
		priority = 79
	})
	MenuHelper:AddSlider({
		id = "fov",
		title = "SpyCam_cam_fov_title",
		callback = "SpyCameraUpdateSettingsCam",
		value = SpyCamera.settings.fov,
		min = 35,
		max = 160,
		step = 8,
		show_value = true,
		menu_id = menu_id_main,
		priority = 79
	})
	MenuHelper:AddDivider({
		id = "divider5",
		size = 24,
		menu_id = menu_id_main,
		priority = 78
	})

	BLT.Keybinds:register_keybind(SpyCamera.mod_instance, { id = "spycam_kb_show_hide", allow_game = true, show_in_menu = false, callback = function()
		if Utils:IsInHeist() then
			SpyCamera.show_cams = not SpyCamera.show_cams
			managers.portal:setPortalCams(SpyCamera.cameras,SpyCamera.show_cams)
		end
	end})
	local key = BLT.Keybinds:get_keybind("spycam_kb_show_hide"):Key() or ""

	MenuHelper:AddKeybinding({
		id = "spycam_kb_show_hide",
		title = "SpyCam_show_hide_title",
		connection_name = "spycam_kb_show_hide",
		binding = key,
		button = key,
		menu_id = menu_id_main,
		priority = 77
	})

	BLT.Keybinds:register_keybind(SpyCamera.mod_instance, { id = "spycam_kb_add_cam", allow_game = true, show_in_menu = false, callback = function()
		if Utils:IsInHeist() then
			SpyCamera:addCamera()
		end
	end})
	local key = BLT.Keybinds:get_keybind("spycam_kb_add_cam"):Key() or ""

	MenuHelper:AddKeybinding({
		id = "spycam_kb_add_cam",
		title = "SpyCam_place_cam_title",
		connection_name = "spycam_kb_add_cam",
		binding = key,
		button = key,
		menu_id = menu_id_main,
		priority = 76
	})
	BLT.Keybinds:register_keybind(SpyCamera.mod_instance, { id = "spycam_kb_remove_cam", allow_game = true, show_in_menu = false, callback = function()
		if Utils:IsInHeist() then
			if #SpyCamera.cameras == 0 then
				return
			end
			local order_num = SpyCamera.settings.remove_order
			if order_num == 1 then
				for i = #SpyCamera.cameras, 1, -1 do
					SpyCamera:removeCam(i)
				end
				managers.portal:setPortalCams({},SpyCamera.show_cams)
			else
				SpyCamera:removeCam(order_num == 2 and #SpyCamera.cameras or 1)
				managers.portal:setPortalCams(SpyCamera.cameras,SpyCamera.show_cams)
				for i, v in pairs(SpyCamera.cameras) do
					SpyCamera:setCameraSlot(i, #SpyCamera.cameras == 1 and true or false)
				end
			end
			
		end
	end})
	local key = BLT.Keybinds:get_keybind("spycam_kb_remove_cam"):Key() or ""

	MenuHelper:AddKeybinding({
		id = "spycam_kb_remove_cam",
		title = "SpyCam_remove_cam_title",
		connection_name = "spycam_kb_remove_cam",
		binding = key,
		button = key,
		menu_id = menu_id_main,
		priority = 75
	})

end)

Hooks:Add("MenuManagerBuildCustomMenus", "MenuManagerBuildCustomMenusSpyCamera", function(menu_manager, nodes)
	nodes[menu_id_main] = MenuHelper:BuildMenu(menu_id_main, { area_bg = "half" })
	MenuHelper:AddMenuItem(nodes["blt_options"], menu_id_main, "SpyCam_main_title", "SpyCam_main_desc")
end)
