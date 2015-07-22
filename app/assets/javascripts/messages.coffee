#-- show a status message ---------------------------------------------------------------------------
window.status_body = (status, html, seconds = null) ->
	color_by_status =
		error: "crimson"
		success: "forestgreen"
		info: "navy"

	#item['specialization'] = window.current_specialization()


	if seconds && seconds > 0
		seconds = seconds * 1000
		state = "on-time"
	else
		state = "static"

	snackbar_html = HandlebarsTemplates['system_navigation_bar']
		bgcolor: color_by_status[status]
		html: html
		state: state
	
#	window.if_console snackbar_html
	
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



#	if seconds == 0
#		$("#status_wrapper > div.data-message").html html
#		$("#status_wrapper > div.data-transparent").css
#			opacity: 0.9
#			"background-color": color_by_status[status]
#		$("#status_wrapper").css
#			top: "0px"
#	else
#		unless seconds
#			seconds = 4
#		seconds *= 1000
#		if $("#status_wrapper > div.data-transparent").is(':animated')
#			$("#status_wrapper > div.data-transparent").stop()
#		if $("#status_wrapper > div.data-message").is(':animated')
#			$("#status_wrapper > div.data-message").stop()
#		if $("#status_wrapper").is(':animated')
#			$("#status_wrapper").stop()
#		$("#status_wrapper").css
#			"background-color": color_by_status[status]
#			top: "0px"
#		$("#status_wrapper > div.data-message").html html
#		left = ($("#status_wrapper").width() - $("#status_wrapper > .data-message").width())/2
#		top = ($("#status_wrapper").height() - $("#status_wrapper > .data-message").height())/2
#		$("#status_wrapper > .data-message").css
#			top: "#{top}px"
#			left: "#{left}px"
#		$("#status_wrapper > div.data-transparent").css
#			opacity: 0.9
#		$("#status_wrapper > div.data-message").css
#			opacity: 1
#		$("#status_wrapper > div.data-transparent").animate
#			opacity: 0
#			WebkitTransition: "opacity 2s ease-in-elastic"
#			MozTransition: "opacity 2s ease-in-elastic"
#			MsTransition: "opacity 2s ease-in-elastic"
#			OTransition: "opacity 2s ease-in-elastic"
#			transition: "opacity 2s ease-in-elastic"
#		, seconds, ->
#		$("#status_wrapper > div.data-message").animate
#			opacity: 0
#		, seconds, ->
#			$("#status_wrapper").css #.animate
#				top: "-200px"
#
##-- close a success, error message by click ---------------------------------------------------------------------------
$(document).click (e)->
	id = window.get_attr(e.target, "id", 3)
#	window.if_console id: id, "e.target": e.target
	if /snackbar/.test(id)
		$("#snackbar").remove()

##-- close a success, error message by click ---------------------------------------------------------------------------
window.close_status = ->
	$("#snackbar.static").remove()

#	id = window.get_attr(e.target, "id", 3)
#	if /_wrapper/.test(id)
#		$("[id$='_wrapper'] > div.data-transparent").css
#			opacity: 0
#		$("[id$='_wrapper']").css
#			top: "-200px"
#
