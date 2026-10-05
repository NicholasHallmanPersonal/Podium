--[[pod_format="raw",created="2026-09-28 14:48:27",modified="2026-10-05 00:25:51",prog="bbs://strawberry_src-15.p64",revision=316,xstickers={}]]
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
include "./elements/image.lua"

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

function new_engine()
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
	
	wc_extend(podkit)
	
	function podkit:retrieve()
		self._is_retrieving = true
		self._content = fetch(self.location)
		self._is_retrieving = false
	end
	
	function podkit:parse()
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

	function podkit:find_hit(elm, frame, mx, my, depth)
		-- have text clicks dispatch as the parent	
		if elm.name == "text" then return nil end
	
		depth = depth or 0
	
		for i = #elm.children, 1, -1 do
			local found, d = self:find_hit(elm.children[i], frame, mx, my, depth + 1)
			if found then return found, d end
		end
	
		local block = draw:to_screen_space(elm.block, frame)
		if mx > block.x and mx < block.x + block.width
		and my > block.y and my < block.y + block.height then
			return elm, depth
		end
	
		return nil
	end
	
	-- border the target, clear everything else
	function podkit:apply_hover(elm, target, target_depth, depth)
		depth = depth or 0
		local new = nil
		if elm == target then new = 8 + target_depth end
	
		if elm.style.border_color != new then
			elm.style.border_color = new
			self.need_draw = true
		end
	
		for child in all(elm.children) do
			self:apply_hover(child, target, target_depth, depth + 1)
		end
	end
	
	function podkit:hit_test(root, frame, events)
		local mx, my = mouse()
		for event in all(events) do
			local mx = event.detail.mouse_x
			local my = event.detail.mouse_y
			local target, depth = self:find_hit(root, frame, mx, my)
			if target != nil then
				target:dispatch(event.type, event.detail)
			end
		end
	end
	
	function podkit:update(frame, events)
		self.last_frame = frame
		
		self:reflow(frame)
		-- for the interactive elements on the page. 
		-- and routing
		self:scroll(frame)
		
		self:hit_test(self.dom, frame, events)	
		
	end
	
	function podkit:init(frame)
		self.last_frame = frame
		self.dom = circumflex_elm{ name="root" }
		add_dom_funcs(self.dom)
		
		self:retrieve() 
		self:parse()
		self:reflow(frame)
	end
	
	return podkit
end

