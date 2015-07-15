#-- show a status message ---------------------------------------------------------------------------
window.status_body = (status, html, seconds = null) ->
	color_by_status =
		error: "crimson"
		success: "forestgreen"
		info: "navy"
	if seconds == 0
		$("#status_wrapper > div.data-message").html html
		$("#status_wrapper > div.data-transparent").css
			opacity: 0.9
			"background-color": color_by_status[status]
		$("#status_wrapper").css
			top: "#{window.getWindowSize().height - 96}px"
	else
		unless seconds
			seconds = 4
		seconds *= 1000
		if $("#status_wrapper > div.data-transparent").is(':animated')
			$("#status_wrapper > div.data-transparent").stop()
		if $("#status_wrapper > div.data-message").is(':animated')
			$("#status_wrapper > div.data-message").stop()
		if $("#status_wrapper").is(':animated')
			$("#status_wrapper").stop()
		$("#status_wrapper").css
			"background-color": color_by_status[status]
			top: "#{window.getWindowSize().height - 96}px"
		$("#status_wrapper > div.data-message").html html
		left = ($("#status_wrapper").width() - $("#status_wrapper > .data-message").width())/2
		top = ($("#status_wrapper").height() - $("#status_wrapper > .data-message").height())/2
		$("#status_wrapper > .data-message").css
			top: "#{top}px"
			left: "#{left}px"
		$("#status_wrapper > div.data-transparent").css
			opacity: 0.9
		$("#status_wrapper > div.data-message").css
			opacity: 1
		$("#status_wrapper > div.data-transparent").animate
			opacity: 0
			WebkitTransition: "opacity 2s ease-in-elastic"
			MozTransition: "opacity 2s ease-in-elastic"
			MsTransition: "opacity 2s ease-in-elastic"
			OTransition: "opacity 2s ease-in-elastic"
			transition: "opacity 2s ease-in-elastic"
		, seconds, ->
		$("#status_wrapper > div.data-message").animate
			opacity: 0
		, seconds, ->
			$("#status_wrapper").css #.animate
				top: "-200px"

#-- close a success, error message by click ---------------------------------------------------------------------------
$(document).click (e)->
	id = window.get_attr(e.target, "id", 3)
	if /_wrapper/.test(id)
		$("[id$='_wrapper'] > div.data-transparent").css
			opacity: 0
		$("[id$='_wrapper']").css
			top: "-200px"

