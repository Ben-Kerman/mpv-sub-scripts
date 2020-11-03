local active = false
local pause_at = 0

local function handle_tick(prop_name, time_pos)
	if time_pos ~= nil and pause_at - time_pos < 0.1 then
		mp.set_property("pause", "yes")
		mp.unobserve_property(handle_tick)
	end
end

local function handle_sub_text_change(prop_name, sub_text)
	mp.unobserve_property(handle_tick)
	if sub_text ~= nil and sub_text ~= '' then
		pause_at = mp.get_property_number("sub-end") + mp.get_property_number("sub-delay")
		mp.observe_property("time-pos", "number", handle_tick)
	end
end

mp.add_key_binding("n", "sub-pause-toggle", function()
	if active then
		mp.unobserve_property(handle_sub_text_change)
		mp.unobserve_property(handle_tick)
		mp.osd_message("Subtitle pausing disabled")
	else
		mp.observe_property("sub-text", "string", handle_sub_text_change)
		mp.osd_message("Subtitle pausing enabled")
	end
	active = not active
end)
