local active = false
local pause_at_start = false
local pause_at_end = false
local skip_next = false
local pause_at = 0

function pause()
	if skip_next then skip_next = false
	else mp.set_property("pause", "yes") end
end

function handle_tick(_, time_pos)
	if time_pos ~= nil and pause_at - time_pos < 0.1 then
		if pause_at_end then pause() end
		mp.unobserve_property(handle_tick)
	end
end

function handle_sub_text_change(_, sub_text)
	mp.unobserve_property(handle_tick)
	if sub_text ~= nil and sub_text ~= "" then
		if pause_at_start then pause() end
		pause_at = mp.get_property_number("sub-end") + mp.get_property_number("sub-delay")
		mp.observe_property("time-pos", "number", handle_tick)
	end
end

function replay_sub()
	-- prevent pause if pausing at start is enabled
	if pause_at_start then skip_next = true end

	local sub_start = mp.get_property_number("sub-start")
	if sub_start ~= nil then
		mp.set_property("time-pos", sub_start + mp.get_property_number("sub-delay"))
		mp.set_property("pause", "no")
	end
end

function display_state()
	local msg
	if active then
		msg = "Subtitle pausing enabled ("
			.. (pause_at_start and "start" or "")
			.. ((pause_at_start and pause_at_end) and " and " or "")
			.. (pause_at_end and "end" or "") .. ")"
	else msg = "Subtitle pausing disabled" end
	mp.osd_message(msg)
end

function toggle()
	if active then
		if not pause_at_start and not pause_at_end then
			pause_at = 0
			skip_next = false
			mp.unobserve_property(handle_sub_text_change)
			mp.unobserve_property(handle_tick)
			active = false
		end
	else
		mp.observe_property("sub-text", "string", handle_sub_text_change)
		active = true
	end
	display_state()
end

mp.add_key_binding(nil, "sub-pause-toggle-start", function()
	pause_at_start = not pause_at_start
	toggle()
end)

mp.add_key_binding("n", "sub-pause-toggle-end", function()
	pause_at_end = not pause_at_end
	toggle()
end)

mp.add_key_binding("Alt+r", "sub-pause-skip-next", function() skip_next = true end)

mp.add_key_binding("Ctrl+r", "sub-pause-replay", function() replay_sub() end)
