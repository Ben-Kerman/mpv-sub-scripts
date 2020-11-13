local active = false
local skip_next = false
local pause_at = 0

function handle_tick(prop_name, time_pos)
	if time_pos ~= nil and pause_at - time_pos < 0.1 then
		if skip_next then skip_next = false
		else mp.set_property("pause", "yes") end
		mp.unobserve_property(handle_tick)
	end
end

function handle_sub_text_change(prop_name, sub_text)
	mp.unobserve_property(handle_tick)
	if sub_text ~= nil and sub_text ~= '' then
		pause_at = mp.get_property_number("sub-end") + mp.get_property_number("sub-delay")
		mp.observe_property("time-pos", "number", handle_tick)
	end
end

function replay_sub()
	local sub_start = mp.get_property_number('sub-start')
	if sub_start ~= nil then
		mp.set_property("time-pos", sub_start + mp.get_property_number('sub-delay'))
		mp.set_property("pause", "no")
	end 
end

mp.add_key_binding("n", "sub-pause-toggle", function()
	if active then
		pause_at = 0
		skip_next = false
		mp.unobserve_property(handle_sub_text_change)
		mp.unobserve_property(handle_tick)
		mp.osd_message("Subtitle pausing disabled")
	else
		mp.observe_property("sub-text", "string", handle_sub_text_change)
		mp.osd_message("Subtitle pausing enabled")
	end
	active = not active
end)

mp.add_key_binding("Alt+r", "sub-pause-skip-next", function() skip_next = true end)

mp.add_key_binding("Ctrl+r", "sub-pause-replay", function() replay_sub() end)
