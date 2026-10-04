--[[pod_format="raw",created="2026-10-04 20:13:51",modified="2026-10-04 22:02:12",revision=54,xstickers={}]]


input = {
	mouse_l_held_frames = 0,
	mouse_r_held_frames = 0
}

function mouse_event(type)
	local mouse_x, mouse_y = mouse()
	return {
		type = type,
		detail = {
			mouse_x = mouse_x,
			mouse_y = mouse_y
		}
	}
end

local click_debounce = 8

function input:get_mouse_left_events(events, pointer)
	
	if pointer.b & 1 == 1 then
		self.mouse_l_held_frames += 1
		if self.mouse_l_held_frames == click_debounce then
			add(events, mouse_event("mouse_down"))
		end
	end
	
	if pointer.b & 1 == 0 and self.mouse_l_held_frames > 0 then
		if self.mouse_l_held_frames < click_debounce then
			add(events, mouse_event("mouse_click"))
		elseif self.mouse_l_held_frames >= click_debounce then
			add(events, mouse_event("mouse_up"))
		end
		self.mouse_l_held_frames = 0
	end
end

function input:get_mouse_right_events(events, pointer)

	if pointer.b & 2 == 2 then
		self.mouse_r_held_frames += 1
		if self.mouse_r_held_frames == click_debounce then
			add(events, mouse_event("mouse_right_held"))
		end
	end
	
	if pointer.b & 2 == 2 and self.mouse_r_held_frames > 0 then
		if self.mouse_r_held_frames < click_debounce then
			add(events, mouse_event("mouse_right_click"))
		elseif self.mouse_l_held_frames >= click_debounce then
			add(events, mouse_event("mouse_right_up"))
		end
		self.mouse_r_held_frames = 0
	end
end

function input:get_scroll_events(events, pointer)
	
	if pointer.wheel != 0 then
		local event = mouse_event("scroll")
		event.detail.scroll = pointer.y
		add(events, event)
	end
	
end

function input:get_events(frame) 
	local events = {}
	
	local mouse_x, mouse_y, mouse_b, wheel_x, wheel_y = mouse()
	local pointer = {
		x = mouse_x,
		y = mouse_y,
		b = mouse_b,
		wheel = wheel_y
	}
	if pointer.x > 0 and pointer.x < frame.width
	and pointer.y > frame.y and pointer.y < frame.height + frame.y then
		input:get_mouse_right_events(events, pointer)
		input:get_mouse_left_events(events, pointer)
		input:get_scroll_events(events, pointer)
	end
	
	
	return events
end