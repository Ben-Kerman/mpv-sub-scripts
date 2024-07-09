-- feel free to modify and/or redistribute as long as you give credit to the original creator; © 2022 Ben Kerman

local cfg = {
	default_start = false,
	default_end = false,
	end_delta = 0.1,
	hide_while_playing = false,
	unpause_time = 0,
	unpause_override = "SPACE",
	replay_prev = true
}
require("mp.options").read_options(cfg)

local active = false
local pause_at_start = cfg.default_start
local pause_at_end = cfg.default_end
local skip_next = false
local pause_at = 0

function set_visibility(state)
	mp.set_property_bool("sub-visibility", state)
	-- force OSD/sub redraw
	mp.osd_message(" ", 0.001)
end

function handle_pause(_, paused)
	if cfg.hide_while_playing and not paused then
		set_visibility(false)
		mp.unobserve_property(handle_pause)
	end
end

function pause()
	if skip_next then skip_next = false
	else
		mp.set_property_bool("pause", true)
		if cfg.hide_while_playing then
			set_visibility(true)
		end
		if cfg.unpause_time > 0 then
			local timer = mp.add_timeout(cfg.unpause_time, function()
				mp.set_property_bool("pause", false)
				mp.remove_key_binding("unpause-override")
			end)
			mp.add_forced_key_binding(cfg.unpause_override, "unpause-override", function()
				timer:kill()
				mp.remove_key_binding("unpause-override")
			end)
		end
		mp.observe_property("pause", "bool", handle_pause)
	end
end

function handle_tick(_, time_pos)
	if time_pos ~= nil and pause_at - time_pos < cfg.end_delta then
		if pause_at_end then pause() end
		mp.unobserve_property(handle_tick)
	end
end

function handle_sub_change(_, sub_end)
	--if no subtitle track loaded then we don't need to try to pause
	if mp.get_property_number('sid', -1) == -1 then
		return
	end
	mp.unobserve_property(handle_tick)
	if sub_end ~= nil then
		if pause_at_start then pause() end
		pause_at = sub_end + mp.get_property_number("sub-delay")
		mp.observe_property("time-pos", "number", handle_tick)
	end
end

function replay_sub()
	-- prevent pause if pausing at start is enabled
	if pause_at_start then skip_next = true end

	local sub_start = mp.get_property_number("sub-start")
	if sub_start ~= nil then
		mp.set_property_number("time-pos", sub_start + mp.get_property_number("sub-delay"))
		mp.set_property_bool("pause", false)
	elseif cfg.replay_prev then
		mp.command("no-osd sub-seek -1")
		mp.set_property_bool("pause", false)
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

local saved_visibility = true

function toggle()
	if active then
		if not pause_at_start and not pause_at_end then
			pause_at = 0
			skip_next = false
			mp.unobserve_property(handle_sub_change)
			mp.unobserve_property(handle_tick)
			active = false
			if cfg.hide_while_playing then
				set_visibility(saved_visibility)
			end
			mp.unobserve_property(handle_pause)
		end
	else
		if cfg.hide_while_playing then
			saved_visibility = mp.get_property_bool("sub-visibility")
			set_visibility(false)
		end
		mp.observe_property("sub-end", "number", handle_sub_change)
		active = true
	end
	display_state()
end

mp.add_key_binding(nil, "toggle-start", function()
	pause_at_start = not pause_at_start
	toggle()
end)

mp.add_key_binding("n", "toggle-end", function()
	pause_at_end = not pause_at_end
	toggle()
end)

mp.add_key_binding("Alt+r", "skip-next", function() skip_next = true end)

mp.add_key_binding("Ctrl+r", "replay", function() replay_sub() end)

if pause_at_start or pause_at_end then
	toggle()
end
