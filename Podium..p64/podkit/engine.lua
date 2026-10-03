--[[pod_format="raw",created="2026-09-28 14:48:27",modified="2026-10-01 11:30:39",prog="bbs://strawberry_src-15.p64",revision=52,xstickers={}]]
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

podkit = {

	location = "podnet://76050/index.txt",
	_is_retrieving = false,
	_content = nil,
	retrieve = function(self)
		printh("retrieving")
		self._is_retrieving = true
		self._content = fetch(self.location)
		printh(type(self._content))
		self._is_retrieving = false
	end,
	
	parse = function(self)
		printh("parsing " .. self._content)
		local parser = new_parser()
		
		parser:parse(self._content)

	end,
	
	run_lifecycle = function(self)
		self:retrieve() 
		self:parse()
	end

}