--[[pod_format="raw",created="2026-10-04 23:25:16",modified="2026-10-05 12:02:54",revision=50,xstickers={}]]
include "./podkit/components.lua"

function make_image()
	local image = {}
	
	function image:promote(elm)
		printh("image promoted")
		local src = elm.attributes.src
		local spr_i = tonumber(elm.attributes.spr) or 1
		printh("downloading " .. src)
		local image = fetch(src)
		
		elm.image_data = image[spr_i].bmp
		elm.style.sizing.width = Fixed(image[spr_i].bmp:width())
		elm.style.sizing.height = Fixed(image[spr_i].bmp:height())
	end
	
	return image
end

define("img", make_image)