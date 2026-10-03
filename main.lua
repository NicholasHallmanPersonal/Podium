--[[pod_format="raw",created="2026-09-28 11:39:55",modified="2026-10-02 22:09:02",prog="bbs://strawberry_src-15.p64",revision=51,xstickers={}]]
include "./chrome/chrome.lua"
include "./podkit/engine.lua"

function _init()
	chrome:init()
	podkit:init(chrome.frame)
end

function _update()
 	chrome:update()
	podkit:update(chrome.frame)
end

function _draw()
  chrome:draw()
  podkit:draw(chrome.frame)
end