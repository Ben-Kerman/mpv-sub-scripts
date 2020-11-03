local active = false

local function pause()
	if not active then return end
	mp.set_property("pause", "yes")
end

local function set_up_timer(prop_name, sub_text)
	if sub_text ~= nil and sub_text ~= '' then
		local sub_end = mp.get_property_number("sub-end")
		local time = mp.get_property_number("time-pos")
		local delay = mp.get_property_number("sub-delay")
		mp.add_timeout(sub_end + delay - time - 0.1, pause)
	end
end

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