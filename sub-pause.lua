local active = false
local pause_timer = nil

local function pause()	
	if not active then return end
	mp.set_property("pause", "yes")
end

local function set_up_timer(prop_name, sub_text)
	if pause_timer ~= nil then 
		pause_timer:stop()
		pause_timer = nil
	end
	
	if sub_text ~= nil and sub_text ~= '' and not mp.get_property_bool('pause') then		
		local sub_end = mp.get_property_number("sub-end")
		local time = mp.get_property_number("time-pos")
		local delay = mp.get_property_number("sub-delay")
		pause_timer = mp.add_timeout(sub_end + delay - time - 0.1, pause)
	end	
end

local function observe_pause(prop_name, pause)
	if pause_timer ~= nil then
		if pause then pause_timer:stop() else pause_timer:resume() end
	else
		set_up_timer('sub-text', mp.get_property('sub-text'))
	end
end

mp.add_key_binding("n", "sub-pause-toggle", function()
	if active then
		mp.unobserve_property(set_up_timer)
		mp.unobserve_property(observe_pause)
		mp.osd_message("Subtitle pausing disabled")
	else
		mp.observe_property("sub-text", "string", set_up_timer)
		mp.observe_property("pause", "bool", observe_pause)
		mp.osd_message("Subtitle pausing enabled")
	end
	active = not active
end)
