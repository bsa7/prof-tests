#--------------------------------------------------------------------------------------------------
window.history_pushState = (page_url, document_title) ->
#	window.if_console "window.history_pushState = (page_url, document_title) ->"

	page_url = page_url.replace(/#+$/, '')
	history.pushState
		page: page_url
		type: "page"
	, document_title, page_url

#-------------------------------------------------------------------------------------------------
window.onpopstate = (e) ->
#	window.if_console "window.onpopstate = (e) ->"

	page_cache = null
	if e.state && e.state.page
		page_cache = window.read_page_cache(e.state.page)
		window.history_pushState e.state.page, document.title 
	if page_cache && page_cache.value
		window.receive_and_draw_page page_cache.value, {page: e.state.page}
	else if e.state && e.state.page
		window.update_page_cache e.state.page
	else
		window.update_page_cache window.current_location()

#--------------------------------------------------------------------------------------------------
window.read_page_cache = (key) ->
#	window.if_console "window.read_page_cache = (key) ->"

	cache = window.varCache("pg##{key}")

#--------------------------------------------------------------------------------------------------
window.save_page_cache = (key, value) ->
#	window.if_console "window.save_page_cache = (key, value) ->"

	window.varCache "pg##{key}", value

#--------------------------------------------------------------------------------------------------
window.receive_and_draw_page = (data, params) ->
#	window.if_console "window.receive_and_draw_page = (data, params) ->"

	if data
		window.save_page_cache params.page, data.html || data
		window.history_pushState params.page, document.title 
		$(window.content_selector).html(data.html || data)
		$(document).scrollTop 0,0
		if window.get_page_sign() == "front"
			window.front_doc_ready()
		else if window.get_page_sign() == "back"
			window.back_doc_ready()
		window.set_on_change_listenter()
		jquery_while_loading = $(".#{window.while_loading_class}")
		if jquery_while_loading.length > 0
			jquery_while_loading.addClass(window.invisible_class)

#--------------------------------------------------------------------------------------------------
window.update_page_cache = (page) ->
#	window.if_console "window.update_page_cache = (page) ->"

	window.get_ajax(page, {format: "html", layout: false, ajaxLoad: true}, window.receive_and_draw_page, {page: page}, true, "GET", "html")
	jquery_while_loading = $(".#{window.while_loading_class}")
	if jquery_while_loading.length > 0
		jquery_while_loading.removeClass(window.invisible_class)

#--------------------------------------------------------------------------------------------------
window.set_page = (page) ->
#	window.if_console "window.set_page = (page) ->"

	cache = window.read_page_cache page
	if cache && cache.value
		window.receive_and_draw_page cache.value, {page: page}
		if window.current_timestamp() - cache.t > window.default_page_live_time #page is obsolete
			window.update_page_cache(page)
	else
		window.update_page_cache(page)

#--------------------------------------------------------------------------------------------------
$(document).click (e)->
#	window.if_console "$(document).click (e)->"

	document_onclick e

#--------------------------------------------------------------------------------------------------
document_onclick = (e) ->
#	window.if_console "navigator: document_onclick = (e) ->"

	if /^[aA]$/.test(e.target.tagName) && /^\//.test(e.target.getAttribute("href")) && !e.target.hasAttribute("data-ajax")
#		console.log "navigator. document_onclick = (e) ->"
		e.preventDefault()
		window.set_page $(e.target).attr("href")
