#-- show a status message ---------------------------------------------------------------------------
window.status_body = (status, html, seconds = null) ->
	color_by_status =
		error: "crimson"
		success: "forestgreen"
		info: "navy"

	if seconds && seconds > 0
		seconds = seconds * 1000
		state = "on-time"
	else
		state = "static"

	snackbar_html = HandlebarsTemplates['system_navigation_bar']
		bgcolor: color_by_status[status]
		html: html
		state: state
	
	$("#snackbar").remove()

	$("body").append(snackbar_html)

	if seconds && seconds > 0

		$("#snackbar > .data-transparent").animate
			opacity: 0
			WebkitTransition: "opacity 2s ease-in-elastic"
			MozTransition: "opacity 2s ease-in-elastic"
			MsTransition: "opacity 2s ease-in-elastic"
			OTransition: "opacity 2s ease-in-elastic"
			transition: "opacity 2s ease-in-elastic"
		, seconds, ->
		$("#snackbar > div.data-message").animate
			opacity: 0
		, seconds, ->
			$("#snackbar").remove()

##-- close a success, error message by click ---------------------------------------------------------------------------
$(document).click (e)->
	id = window.get_attr(e.target, "id", 3)
#	window.if_console id: id, "e.target": e.target
	if /snackbar/.test(id)
		$("#snackbar").remove()

##-- close a success, error message by click ---------------------------------------------------------------------------
window.close_status = ->
	$("#snackbar.static").remove()
