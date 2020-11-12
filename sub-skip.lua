local active = false
local sped_up = false
local min_skip_time = 3
local start_offset = 0
local end_offset = 1
local speed_skip_speed = 2.5
local skip_start, skip_end

function calc_next_delay()
	local initial_delay = mp.get_property_number("sub-delay")

	mp.commandv("sub-step", "1")
	local new_delay = mp.get_property_number("sub-delay")
	mp.set_property_number("sub-delay", initial_delay)

	local ret
	if new_delay == initial_delay then ret = nil
	else ret = -(new_delay - initial_delay) end

	return ret
end

local initial_speed = 1
function handle_tick(prop_name, time_pos)
	if not sped_up and time_pos > skip_start then
		initial_speed = mp.get_property_number("speed")
		mp.set_property_number("speed", speed_skip_speed)
		sped_up = true
	elseif sped_up and time_pos > skip_end then
		mp.unobserve_property(handle_tick)
		mp.set_property_number("speed", initial_speed)
		sped_up = false
		skip_start, skip_end = nil
	end
end

function handle_sub_text_change(prop_name, sub_text)
	if sub_text ~= nil and sub_text == "" then
		local next_delay = calc_next_delay()
		if next_delay < min_skip_time then return
		else
			local time_pos = mp.get_property_number("time-pos")
			skip_start = time_pos + start_offset
			skip_end = time_pos + next_delay - end_offset
			mp.observe_property("time-pos", "number", handle_tick)
		end
	end
end

mp.add_key_binding("Ctrl+n", "sub-skip-toggle", function()
	if active then
		skip_start, skip_end = nil
		mp.unobserve_property(handle_sub_text_change)
		mp.unobserve_property(handle_tick)
		mp.osd_message("Non-subtitle skip disabled")
	else
		mp.observe_property("sub-text", "string", handle_sub_text_change)
		mp.osd_message("Non-subtitle skip enabled")
	end
	active = not active
end)
