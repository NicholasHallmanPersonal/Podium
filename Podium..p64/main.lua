--[[pod_format="raw",created="2026-09-28 11:39:55",modified="2026-10-01 11:30:05",prog="bbs://strawberry_src-15.p64",revision=40,xstickers={}]]
include "./chrome/chrome.lua"
include "./podkit/engine.lua"

function _init()
	chrome:init()
end

function _update()
  chrome:update()

	if podkit._content == nil 
	and podkit._is_retrieving == false then
		podkit:run_lifecycle()
	end
end

function _draw()
  chrome:draw()
end