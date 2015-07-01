#-----------------------------------------------------------------------------------
window.touch_image = (data, params) ->
	img_src = params["img_src"]
	$("img[src='#{img_src}']").attr("src", img_src)

#-----------------------------------------------------------------------------------
window.bg_image_error_handling = (bg_image) ->
	#on "error" event on image load (404 url not found error)
	if (bg_image && bg_image.complete && bg_image.naturalWidth == 0) || bg_image && !bg_image.complete
		window.get_ajax "/render_background", { filename: bg_image.getAttribute("data-origin") }, window.touch_image, { img_src: bg_image.getAttribute('src') }, true, "GET", "json"
