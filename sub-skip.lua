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
