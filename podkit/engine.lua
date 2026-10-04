--[[pod_format="raw",created="2026-09-28 14:48:27",modified="2026-10-04 02:35:42",prog="bbs://strawberry_src-15.p64",revision=252,xstickers={}]]
--[[
PodKit Engine Stages

	Retrieve
	Parse and Style
	Layout
	Scroll
	Paint
	Draw
]]

include "./podkit/parser.lua"
include "./ui/lib.lua"
include "./ui/draw.lua"
include "./podkit/components.lua"

function debug_dom(elm, l)
	local level = l or 1
	local s = ""
	for i = 1, level, 1 do
		s ..= " "
	end
	
	s ..= elm.name
	for k,v in pairs(elm.attributes) do
		s ..= " " .. k .. " = " .. v
	end
	
	if #elm.content > 0 then
		s ..= " " .. elm.content
	end
	printh(s)
	for child in all(elm.children) do
		debug_dom(child, level + 1)
	end
end

podkit = {
	location = "podnet://76050/index.txt",
	_is_retrieving = false,
	_content = nil,
	dom = nil,
	body = nil,
	need_draw = true,
	last_frame = nil,
	hit_boxes = {}
}

function podkit:retrieve()
	printh("retrieving")
	self._is_retrieving = true
	self._content = fetch(self.location)
	printh(type(self._content))
	self._is_retrieving = false
end

function podkit:parse()
	printh("parsing " .. self._content)
	local parser = new_parser()
	self.body = parser:parse(self._content, self.dom)
end

function podkit:reflow(frame)
	self.last_frame = frame
	
	local changed = false
	if self.body.block.width != frame.width then
		self.body.style.sizing.width = Fixed(frame.width)
		changed = true
	end 
	if changed then
		self:layout()
		self.need_draw = true
	end
end

function podkit:layout()
	circumflex_layout(self.body)
end

function podkit:scroll(frame)
	self.last_frame = frame
	-- we know the total possible body height so we limit the
	-- scroll position to it
	local scroll_speed = 3
	local pre_scroll = frame.scroll
	-- change the frame scroll position
	if btn(2) then
		frame.scroll -= scroll_speed
		if frame.scroll < 0 then frame.scroll = 0 end
	end

	local scroll_offset = (self.body.block.height - frame.height) + frame.y 
	if btn(3) then
		frame.scroll += scroll_speed
		if frame.scroll > scroll_offset then
			frame.scroll = max(0, scroll_offset)
		end
	end
	if pre_scroll != frame.scroll then
		self.need_draw = true
	end
	frame.scroll_offset = scroll_offset
	
end

function podkit:draw(frame)
	self.last_frame = frame
	if not self.need_draw then return end
	local draw_list = draw:make_draw_list(self.body, frame)
	draw:draw_layout(draw_list, frame)
	self.need_draw = false
end

function podkit:hit_test(elm, frame, selected)
	-- take the mouse position and determine  
	-- which element is being hovered
	
	local child_selected = selected or false
	
	if child_selected then
		elm.style.border_color = 8
		self.need_draw = true
	end
	
	for child in all(elm.children) do
		child_selected = podkit:hit_test(child, frame, child_selected) or child_selected
	end
	
	if child_selected then
		elm.style.border_color = 8
		self.need_draw = true
		return true
	end
	
	local mouse_x, mouse_y, mouse_b, wheel_x, wheel_y = mouse()
	local block = draw:to_screen_space(elm.block, frame)
	
	if mouse_x > block.x and mouse_x < block.x + block.width
	and mouse_y > block.y and mouse_y < block.y + block.height then
		elm.style.border_color = 8
		self.need_draw = true
		return true
	end 
	elm.style.border_color = nil
	self.need_draw = true
	return false
	
end

function podkit:init(frame)
	self.last_frame = frame
	self.dom = circumflex_elm{ name="root" }
	add_dom_funcs(self.dom)
	
	self:handle_events(self.dom)
	
	self:retrieve() 
	self:parse()
	self:reflow(frame)
end

function podkit:update(frame)
	self.last_frame = frame
	self:reflow(frame)
	-- for the interactive elements on the page. 
	-- and routing
	self:scroll(frame)
	
	local mouse_x, mouse_y, mouse_b, wheel_x, wheel_y = mouse()
	if mouse_x > 0 and mouse_x < frame.width
	and mouse_y > frame.y and mouse_y < frame.height + frame.y then
		self:hit_test(self.dom, frame)	
	end
	
end

wc_extend(podkit)

function podkit:handle_events(root)
	root.listeners["click"] = function(e) 
		if e.target.name == "a" then
			-- navigate!
			local next_url = e.target.attributes["href"]
			podkit.location = next_url
			podkit._is_retrieving = false
			podkit._content = nil
			self.dom.children = {}
			self.body = nil
			self.need_draw = true
			
			self:retrieve() 
			self:parse()
			self:reflow(self.last_frame)
		end
	end
end