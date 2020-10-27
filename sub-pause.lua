local function pause()
	mp.set_property("pause", "yes")
end

local function set_up_timer(prop_name, sub_text)
	local time = mp.get_property("time-pos")
	if sub_text ~= '' then
		local sub_end = mp.get_property_number("sub-end")
		local time = mp.get_property_number("time-pos")
		if type(sub_end) == "number" and type(time) == "number" then
			mp.add_timeout(sub_end - time, pause)
		end
	end
end

local active = false

mp.add_key_binding("n", "sub-pause-toggle", function()
	if active then
		mp.unobserve_property(set_up_timer)
		mp.osd_message("Subtitle pausing disabled")
	else
		mp.observe_property("sub-text", "string", set_up_timer)
		mp.osd_message("Subtitle pausing enabled")
	end
	active = not active
end)