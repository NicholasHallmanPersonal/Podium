--[[pod_format="raw",created="2026-09-28 14:48:27",modified="2026-10-03 01:13:48",prog="bbs://strawberry_src-15.p64",revision=124,xstickers={}]]
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
	body = nil
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
	self.dom, self.body = parser:parse(self._content)
	debug_dom(self.dom)
end

function podkit:reflow(frame)

	local changed = false
	printh("block width " ..  self.body.block.width)
	if self.body.block.width != frame.width then
		self.body.style.sizing.width = Fixed(frame.width)
		changed = true
	end 
	printh("block height " ..  self.body.block.height)
	if self.body.block.height != frame.height then
		self.body.style.sizing.height = Fixed(frame.height)
		changed = true
	end
	if changed then 
		printh("reflow again")
		self:layout() 
	end
end

function podkit:layout()
	circumflex_layout(self.body)
end

function podkit:draw(frame)
	local draw_list = draw:make_draw_list(self.body)
	draw:draw_layout(draw_list, frame)
end

function podkit:init(frame)
	self:retrieve() 
	self:parse()
	self:reflow(frame)
end

function podkit:update(frame)
	self:reflow(frame)
	-- for the interactive elements on the page. 
	-- and routing
end

