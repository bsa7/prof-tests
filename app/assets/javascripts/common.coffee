'use strict'
window.cache = {}

#--------------------------------------------------------------------------------------------------
window.set_on_change_listenter =  ->
#	window.if_console "window.set_on_change_listenter =  ->"

#	if !window.need_run("window.set_on_change_listenter")
#		return
	form_elements = [
		"input"
		"select"
		"textarea"
#			".sliders"
	]
	for element_selector in form_elements
		if $(element_selector).length > 0
			$(element_selector).on
				blur: ->
					on_field_change(@.id)
				change: ->
					on_field_change(@.id)

#--------------------------------------------------------------------------------------------------
on_field_change = (id) ->
	if window.get_page_sign() == window.frontend_sign
		window.store_form_values()
		window.update_specialization_index 10, true					
		window.on_main_performer_price_change(id)
		window.on_specialization_change(id)

#--------------------------------------------------------------------------------------------------
window.on_specialization_change = (id) ->
	if $(window.performers_filter_selector).length == 0
		return
	if "select##{id}" == window.search_by_specialization_selector && window.current_location() != "/"
		window.history_pushState $("select##{id}").val()

#--------------------------------------------------------------------------------------------------
window.on_main_performer_price_change = (id) ->
#	window.if_console "window.on_main_performer_price_change = (id) ->"

	main_performer_price_attr = "main-performer-price"
#	window.if_console id: id, main_performer_price_attr: main_performer_price_attr, test: new RegExp(main_performer_price_attr).test(id)
	if new RegExp(main_performer_price_attr).test(id)
		jquery_main_performer_price = $("##{main_performer_price_attr}")
		jquery_commission_summ = $("#commission-summ")
		if jquery_main_performer_price.length > 0
			if jquery_main_performer_price.val() > 20000
				jquery_commission_summ.val 10000
			else
				jquery_commission_summ.val 5000
			$("#total-performer-cost").val parseInt(jquery_main_performer_price.val()) + parseInt(jquery_commission_summ.val())

#--------------------------------------------------------------------------------------------------
window.datetime_picker_initialize = ->
#	window.if_console "window.datetime_picker_initialize = ->"

	if $(window.date_class_selector).length > 0
		$(window.date_class_selector).pickmeup
			change: window.date_picker_change

#--------------------------------------------------------------------------------------------------
window.varCache = (key, value) ->
#	window.if_console "window.varCache = (key, value) ->"

	res = null
	unless typeof window.localStorage is "undefined"
		if key && value
			timestamp = window.current_timestamp()
			try
				if /^pg#/.test(key) #compress html only
					cache_value = 
						v: LZString.compressToUTF16(value.replace(/(?:\\[rn]|[\r\n]+)+/g, ""))
						t: timestamp
				else
					cache_value = 
						v: value
						t: timestamp
			catch
				alert "Невозможно сжать содержимое кэша для хранилища: "
			try
				value_json = JSON.stringify(cache_value)
				if value_json
					window.localStorage.setItem(key, value_json)
			catch e
				alert "Локальное хранилище переполнено"  if e is QUOTA_EXCEEDED_ERR
		if key && !value
			stored_json = window.localStorage.getItem(key)
			if stored_json
				res = JSON.parse(stored_json)
				if /^pg#/.test(key)
					res.value = LZString.decompressFromUTF16(res.v)
				else
					res.value = res.v
			else
				res = 
					v: null
					t: null
					value: null
	else
		if key && value
			NavigationCache[key] = value
		if key && !value
			res = NavigationCache[key]
	return res

#--------------------------------------------------------------------------------------------------
window.if_console = (params) ->
	if true
		console.log params

#--------------------------------------------------------------------------------------------------
window.objects_equal = (obj1, obj2) ->
#	window.if_console "window.objects_equal = (obj1, obj2) ->"

	JSON.stringify(obj1) == JSON.stringify(obj2)

#--------------------------------------------------------------------------------------------------
window.need_run = (proc_name, delta = 1) ->
	cache_name = "lr##{proc_name}"
	last_run = window.varCache(cache_name)
	window.varCache(cache_name, "...")
	res = true
#	if last_run
	if last_run && last_run.t && window.current_timestamp() - last_run.t < delta * 1000
		res = false
#	window.if_console "window.need_run = (#{proc_name}, delta = 1) -> #{res}"
	return res

#--------------------------------------------------------------------------------------------------
window.stop = (e) ->
#	window.if_console "window.stop = (e) ->"
	if e.preventDefault
		e.preventDefault()
		e.stopPropagation()
	else
		e.returnValue = false
		e.cancelBubble = true
	return

#--------------------------------------------------------------------------------------------------
window.is_empty = (value) ->
#	window.if_console "window.is_empty = (value) ->"

	switch typeof(value)
		when "object"
			res = true
			for prop of value
				if value.hasOwnProperty(prop)
					res = false
					break
			res
		when "number"
			false
		when "string"
			value == ""
		when "undefined"
			true
		else
			false

#--------------------------------------------------------------------------------------------------
window.calculate_visibilities = (params) ->
#	window.if_console "window.calculate_visibilities = (params) ->"

	res = {}
	res.document_height = params.jquery_document.height()
	params.document_height = res.document_height
	res.is_header_visible = params.scroll_top < params.header_height - params.top_menu_height
	res.is_footer_visible = res.document_height - params.view_size.height - params.scroll_top - params.footer_height <= 0
	if params.view_size.height < params.performers_filter_height
		res.is_footer_reachable = res.document_height - params.scroll_top - params.footer_height <= params.performers_filter_height + params.top_menu_height
	else
		res.is_footer_reachable = res.document_height - params.performers_filter_height - params.scroll_top - params.footer_height - params.top_menu_height <= 0
	res

#--------------------------------------------------------------------------------------------------
window.numberWithCommas = (x) ->
#	window.if_console "window.numberWithCommas = (x) ->"

	parts = x.toString().split(".")
	parts[0] = parts[0].replace(/\B(?=(\d{3})+(?!\d))/g, " ")
	parts.join "."

#--------------------------------------------------------------------------------------------------
window.fancybox_init = ->
#	window.if_console "window.fancybox_init = ->"

	$(".fancybox").fancybox
		beforeLoad: ->
			@title = $(@element).attr("caption")
		helpers:
			overlay:
				locked: false

#--------------------------------------------------------------------------------------------------
window.myFireEvent = (event_name) ->
#	window.if_console "window.myFireEvent = (event_name) ->"

	event = undefined # The custom event that will be created
	if document.createEvent
		event = document.createEvent("HTMLEvents")
		event.initEvent event_name, true, true
	else
		event = document.createEventObject()
		event.eventType = event_name
	event.eventName = event_name
	if document.createEvent
		element.dispatchEvent event
	else
		element.fireEvent "on" + event.eventType, event

#--------------------------------------------------------------------------------------------------
window.current_timestamp = ->
#	window.if_console "window.current_timestamp = ->"

	new Date().getTime()

#--------------------------------------------------------------------------------------------------
window.current_date = (inc_days = 0) ->
#	window.if_console "window.current_date = (inc_days = 0) ->"

	date = new Date()
	date.setDate(date.getDate() + inc_days)
	date.getDate() + ' ' + (window.date_time_names["fullMonthNames"][date.getMonth()]) + ' ' + date.getFullYear()

#--------------------------------------------------------------------------------------------------
window.getWindowSize = ->
#	window.if_console "window.getWindowSize = ->"

	isDocumentElementHeightOff = ->
		d = document
		div = d.createElement("div")
		div.style.height = "2500px"
		d.body.insertBefore div, d.body.firstChild
		r = d.documentElement.clientHeight > 2400
		d.body.removeChild div
		r
	docEl = document.documentElement
	IS_BODY_ACTING_ROOT = docEl and docEl.clientHeight is 0
	if typeof document.clientWidth is "number"
		width: document.clientWidth
		height: document.clientHeight
	else if IS_BODY_ACTING_ROOT or isDocumentElementHeightOff()
		b = document.body
		width: b.clientWidth
		height: b.clientHeight
	else
		width: docEl.clientWidth
		height: docEl.clientHeight
		
#--------------------------------------------------------------------------------------------------
window.get_attr = (element, attr_name, depth = 1) ->
#	window.if_console "window.get_attr = (element, attr_name, depth = 1) ->"

	res = []
	r = element
	for level in [1..depth]
		if r
			res.push $(r).attr(attr_name)
			r = r.parentNode
	res.first_not_empty()

#--------------------------------------------------------------------------------------------------
String::alltrim = ->
	this.replace(/\n/g,'').replace(/^\s*/,'').replace(/\s*$/,'')

#--------------------------------------------------------------------------------------------------
Array::scan = (value) ->
	this.indexOf value || -1

#--------------------------------------------------------------------------------------------------
Array::max = ->
	Math.max.apply null, this

#--------------------------------------------------------------------------------------------------
Array::min = ->
	Math.min.apply null, this

#--------------------------------------------------------------------------------------------------
Array::first_not_empty = ->
	res = null
	for res in this
		if res
			break
	res

#--------------------------------------------------------------------------------------------------
window.activate_first_input = (selector) ->
#	window.if_console "window.activate_first_input = (selector) ->"

	$("#{selector} input[type!=hidden]:first").focus()

#--------------------------------------------------------------------------------------------------
window.dialog = (html) ->
#	window.if_console "window.dialog = (html) ->"

	id = "dialog#{window.current_timestamp()}"
	$.fancybox
		content: "<div id='fancybox-content'>#{html}</div>"
		padding: 40
		tpl:
			closeBtn: "<span id=\"cancel\" class=\"m10 pull-right fancybox-item fancybox-close fancy-close glyph glyph-remove glyph-close\"></span>"
		helpers:
			overlay:
				locked: false
				speedOut: 500
				css:
					'background-color': 'rgba(11,11,11,0.2)'
		afterShow: ->
			window.activate_first_input("#fancybox-content")
#			$("#fancybox-content input[type!=hidden]:first").focus()

#--------------------------------------------------------------------------------------------------
window.render_page = (page_html, page_url = "") ->
#	window.if_console "window.render_page = (page_html, page_url = \"\") ->"

	$.fancybox.close()
	if /full-screen/.test page_html
		$(window.content_selector).html(page_html)
		window.activate_first_input(window.content_selector)
		if page_url
			history.pushState
				page: page_url
				type: "page"
			, document.title, page_url
			window.varCache "pg##{page_url}", page_html
	else
		dialog page_html
	window.front_doc_ready()

#--------------------------------------------------------------------------------------------------
window.get_ajax = (url, data_adds, callback = null, callback_params = null, async = true, query_type = "GET", datatype = "json") ->
#	window.if_console "window.get_ajax = (#{url}, data_adds, callback = null, callback_params = null, #{async}, #{query_type}, #{datatype}) ->"

#	window.if_console "get_ajax. async: #{async}"
	data =
		utf8: "\?"
		layout: false
		authenticity_token: window.get_token()
	for key, val of data_adds
		data[key] = val
	$.ajax
		async: async
		type: query_type
		datatype: datatype
		data: data
		url: url
		error: (data) ->
			if callback
				callback(data, callback_params)
			else
				data
		success: (data) ->
			if callback
				callback(data, callback_params)
			else
				data

#--------------------------------------------------------------------------------------------------
window.timezone_name = ->
#	window.if_console "window.timezone_name = ->"

	Intl.DateTimeFormat().resolvedOptions().timeZone

#--------------------------------------------------------------------------------------------------
window.get_token = ->
#	window.if_console "window.get_token = ->"

	$('meta[name="csrf-token"]').attr('content')

#-- show a status message ---------------------------------------------------------------------------
window.status_body = (status, html, seconds = null) ->
#	window.if_console "window.status_body = (status, html, seconds = null) ->"

	wrapper = "_wrapper"
	div = "div"
	if seconds == 0
		$("##{status}#{wrapper} > #{div}.data-message").html html
		$("##{status}#{wrapper} > #{div}.data-transparent").css
			opacity: 0.9
		$("##{status}#{wrapper}").css
			top: "0px"
	else
		unless seconds
			seconds = 4
		seconds *= 1000
		if $("##{status}#{wrapper} > #{div}.data-transparent").is(':animated')
			$("##{status}#{wrapper} > #{div}.data-transparent").stop()
		if $("##{status}#{wrapper} > #{div}.data-message").is(':animated')
			$("##{status}#{wrapper} > #{div}.data-message").stop()
		if $("##{status}#{wrapper}").is(':animated')
			$("##{status}#{wrapper}").stop()
		$("##{status}#{wrapper}").css
			opacity: 0.9
			top: "0px"
		$("##{status}#{wrapper} > #{div}.data-message").html html
		left = ($("##{status}#{wrapper}").width() - $("##{status}#{wrapper} > .data-message").width())/2
		top = ($("##{status}#{wrapper}").height() - $("##{status}#{wrapper} > .data-message").height())/2
		$("##{status}#{wrapper} > .data-message").css
			top: "#{top}px"
			left: "#{left}px"
		$("##{status}#{wrapper} > #{div}.data-transparent").css
			opacity: 0.9
		$("##{status}#{wrapper} > #{div}.data-message").css
			opacity: 1
		$("##{status}#{wrapper} > #{div}.data-transparent").animate
			opacity: 0
			WebkitTransition: "opacity 2s ease-in-elastic"
			MozTransition: "opacity 2s ease-in-elastic"
			MsTransition: "opacity 2s ease-in-elastic"
			OTransition: "opacity 2s ease-in-elastic"
			transition: "opacity 2s ease-in-elastic"
		, seconds, ->
		$("##{status}#{wrapper} > #{div}.data-message").animate
			opacity: 0
		, seconds, ->
			$("##{status}#{wrapper}").css #.animate
				opacity: 0
				top: "-200px"

##- disable hover while page scrolling -------------------------------------------------------------
#window.addEventListener "scroll", (->
#	body = document.body
#	timer = undefined
#	clearTimeout timer
#	body.classList.add "disable-hover" unless body.classList.contains("disable-hover")
#	timer = setTimeout(->
#		body.classList.remove "disable-hover"
#		return
#	, 500)
#	return
#), false

'use strict'

#--------------------------------------------------------------------------------------------------
window.save_current_page = ->
#	window.if_console "window.save_current_page = ->"

	content = $("#content").html()
	window.varCache window.current_location(), content

#--------------------------------------------------------------------------------------------------
window.current_location = ->
#	window.if_console "window.current_location = ->"

	decodeURI(window.location.pathname + window.location.search)

#--------------------------------------------------------------------------------------------------
window.get_form_fields = (v) ->
#	window.if_console "window.get_form_fields = (v) ->"

	field_value_caller = if v then v.split(/\(|\)/) else []
	field_value_func_name = field_value_caller[0]
	field_value_params = if field_value_caller[1] then field_value_caller[1].replace(/\'|\"/g,'').split(',') else []
	if field_value_params.length == 1
		field_value_params = field_value_params[0]
	else if field_value_params.length == 0
		field_value_params = ""
	[field_value_func_name, field_value_params]

#--------------------------------------------------------------------------------------------------
window.get_specialization_name = (url) ->
#	window.if_console "window.get_specialization_name = (url) ->"

	url_specialization = undefined 
	decoded_uri = decodeURIComponent(url)
	if decoded_uri
		url_specialization_matches = decoded_uri.match(/[^\/]+$/)
		if url_specialization_matches && url_specialization_matches.length > 0
			url_specialization = url_specialization_matches[0]
	url_specialization

#--------------------------------------------------------------------------------------------------
window.store_form_values = ->
#	window.if_console "window.store_form_values = ->"

#	if !window.need_run("window.store_form_values", 0.04) #25 fps
#		return
	params = {}
	for elem in $("[data-storeable]")
		tagName = $(elem).prop("tagName").toLowerCase()
		if /input/.test(tagName) && elem.getAttribute("type") == "checkbox"
			params["checkbox##{$(elem).prop('id')}"] = elem.checked
		else if /select|input|textarea/.test(tagName) || (/div/.test(tagName) && /sliders/.test($(elem).attr("class")))
			params["#{tagName}##{$(elem).prop('id')}"] = $(elem).val()
		else if /label/.test(tagName)
			params["#{tagName}##{$(elem).prop('id')}"] = $(elem).text().alltrim()
	if !window.is_empty(params)
		window.varCache("sv#{window.current_location()}", params)

#--------------------------------------------------------------------------------------------------
window.restore_form_values = ->

	cache = window.varCache("sv#{window.current_location()}")
	if cache && !cache.value || !cache
		window.store_form_values()
	cache = window.varCache("sv#{window.current_location()}")
	if cache && cache.value
		for key, value of cache.value
			if /^checkbox/.test(key)
				id = key.replace(/^checkbox#/,'')
				if document.getElementById(id)
					document.getElementById(id).checked = value
			else if /^(select|input|textarea)/.test(key) || (/^div/.test(key) && /slider/.test(key))
				if $(key).length > 0
					$(key).val(value)

#--------------------------------------------------------------------------------------------------
window.read_form_values = ->
#	window.if_console "window.read_form_values = ->"
	window.varCache("sv#{window.current_location()}").value

#--------------------------------------------------------------------------------------------------
window.set_style = (selector, rules) ->
#	window.if_console "window.set_style = (selector, rules) ->"

	css_selector = "cs#{selector.replace(/[\.\,#]/, '-')}"
#	window.if_console $("style##{css_selector}")
	#$("style##{css_selector}").remove()
	sheet = document.createElement("style")
	sheet.id = css_selector
	style_str = "#{selector} {<rules>}"
	rules_str = ""
	for key of rules
		rules_str += "#{key}: #{rules[key]};"
	sheet.innerHTML = style_str.replace("<rules>", rules_str);
	if !document.getElementById(css_selector)
		document.body.appendChild sheet
	else
		document.getElementById(css_selector).innerHTML = sheet.innerHTML

#--------------------------------------------------------------------------------------------------
window.popup = (html) ->

	popup = document.createElement("div")
	popup.className = window.popup_class
	popup.innerHTML = html
	back_stage = document.createElement("div")
	back_stage.className = window.back_stage_class
	document.body.appendChild back_stage
	document.body.appendChild popup

#--------------------------------------------------------------------------------------------------
window.initialize_checkboxes = ->
#	window.if_console "window.initialize_checkboxes = ->"

	for checkbox in $("input[type='checkbox']")
		id = checkbox.getAttribute("id")
		label_text = checkbox.getAttribute("data-label")
		window.set_style("input##{id}:after", [["content", "'#{label_text}'"]])

#-- make random id string -------------------------------------------------------------------------
window.makeid = (length_of) ->
#	window.if_console "window.makeid = (length_of) ->"

	text = ""
	possible = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
	i = 0
	while i < length_of
		text += possible.charAt(Math.floor(Math.random() * possible.length))
		i++
	text

#--------------------------------------------------------------------------------------------------
window.init_session = ->
#	window.if_console "window.init_session = ->"

	sId = "sId"
	cacheSessionId = varCache sId
	if !cacheSessionId || !cacheSessionId.value
		varCache sId, window.makeid 32

#--------------------------------------------------------------------------------------------------
window.insert_rows = (data, params) ->
	$(".table > table").append(data)

#--------------------------------------------------------------------------------------------------
window.get_parent_model_name = ->
	$("[#{window.data_parent_model_name_attr}]").attr(window.data_parent_model_name_attr)

#--------------------------------------------------------------------------------------------------
window.get_parent_record_id = ->
	$("[#{window.data_parent_model_name_attr}]").attr(window.data_parent_record_id_attr)

#--------------------------------------------------------------------------------------------------
window.url_by_model = (id = null) ->
#	console.log $('[data-model]')
	url = "/admin/#{window.get_parent_model_name()}"
	if id
		url = url + "/#{id}"
	url

#--------------------------------------------------------------------------------------------------
window.set_file_listener = (model_name = null) ->
	$("#input-file").change (e) ->
		window.upload_performer_photos(e, window.upload_preview_selector)
	$("#upload-other-performer-photos").change (e) ->
		window.upload_performer_photos(e, "#devise-other-performer-photos")
	$("#upload-performer-avatar").change (e) ->
		window.upload_performer_avatar(e)
	$("#upload-main-performer-photo").change (e) ->
		window.upload_main_performer_photo(e)

#--------------------------------------------------------------------------------------------------
window.upload_performer_photos = (e, upload_preview_selector) ->
	style_template = "!!!style!!!"
	unless model_name
		model_name = window.get_parent_model_name()
	existing_file_ids = []
	input = $(e.currentTarget)
	id = input.attr("id")
	#window.if_console id: id, "window.upload_preview_selector": window.upload_preview_selector
	readers = []
	for file in input[0].files
		file_id = window.makeid(7)
		template_name = "img_thumb"
		fast_preview = HandlebarsTemplates[template_name]({"data-model": model_name, thumb: "/assets/images/thumb_dumb.gif", attachment_comment: file.name, id: file_id})
		$(upload_preview_selector).append(fast_preview)
		#$(window.upload_preview_selector).hide().show(0)
		o = new FileReader()
		o.file_id = file_id
		o.file = file
		o.readAsDataURL file
		o.onload = (e) -> #Загружено с диска в память браузера
			image_base64 = e.target.result
			image_hash = sha512(image_base64)
			preview = HandlebarsTemplates[template_name]({"data-model": model_name, thumb: image_base64, thumb: image_base64, attachment_comment: @file.name, id: @file_id, image_hash: image_hash})
			pic_real_width = undefined
			pic_scaled_width = undefined
			pic_real_height = undefined
			pic_scaled_height = 200
			preloaded_image = $("<img id='#{@file_id}'/>")
			preloaded_image.file_id = @file_id
			preloaded_image.load( ->
				preloaded_image_id = $(this)[0].id
				$("##{preloaded_image_id}").replaceWith(preview)
				pic_real_width = @width
				pic_real_height = @height
				pic_scaled_width = pic_real_width * (pic_scaled_height / pic_real_height)
				$("##{preloaded_image_id} img").css
					width: "#{pic_scaled_width}px"
					height: "#{pic_scaled_height}px"
				return
			).attr("src", image_base64)
			record_id = window.get_parent_record_id()
			window.upload @file, @file_id, image_hash, model_name, record_id, preloaded_image[0].width, preloaded_image[0].height
	document.getElementById(id).value = "";

#--------------------------------------------------------------------------------------------------
window.upload_performer_avatar = (e) ->
	style_template = "!!!style!!!"
	unless model_name
		model_name = window.get_parent_model_name()
	existing_file_ids = []
	input = $(e.currentTarget)
	id = input.attr("id")
	#window.if_console id: id, "window.upload_preview_selector": window.upload_preview_selector
	readers = []
	for file in input[0].files
		file_id = window.makeid(7)
		template_name = "avatar_preview"
		fast_preview = HandlebarsTemplates[template_name]({"data-model": model_name, thumb: "/assets/images/thumb_dumb.gif", attachment_comment: file.name, id: file_id})

		window.popup fast_preview

		o = new FileReader()
		o.file_id = file_id
		o.file = file
		o.readAsDataURL file
		o.onload = (e) -> #Загружено с диска в память браузера
			image_base64 = e.target.result
			#window.if_console "image64 loaded"
			#window.if_console image_base64
			image_hash = sha512(image_base64)
			preview = HandlebarsTemplates[template_name]({"data-model": model_name, src: image_base64, thumb: image_base64, attachment_comment: @file.name, id: @file_id, image_hash: image_hash})
			pic_real_width = undefined
			pic_scaled_width = undefined
			pic_real_height = undefined
			pic_scaled_height = 200
			$(".popup").html preview
			$(".popup img").css
				height: "400px"
				top: "#{(window.getWindowSize().height - 400) / 2}px"
			pic_scaled_height = [window.getWindowSize().height * 0.8, 400].min()
			preloaded_image = $("<img id='#{@file_id}'/>")
			preloaded_image.file_id = @file_id
			preloaded_image.load( ->
				preloaded_image_id = $(this)[0].id
				$("##{preloaded_image_id}").replaceWith(preview)
				pic_real_width = @width
				pic_real_height = @height
				pic_scaled_width = pic_real_width * (pic_scaled_height / pic_real_height)
				styles = [[window.top_attr, "#{(window.getWindowSize().height - pic_scaled_height) / 2}px"], [window.left_attr, "#{(window.getWindowSize().width - pic_scaled_width) / 2}px"]]
				window.set_style ".popup", styles
#						$("##{preloaded_image_id} img").faceDetection complete: (faces) ->
#  						window.if_console faces: faces
				$("##{preloaded_image_id} img").css
					width: "#{pic_scaled_width}px"
					height: "#{pic_scaled_height}px"
				return
			).attr("src", image_base64)
			record_id = window.get_parent_record_id()
			window.upload @file, @file_id, image_hash, model_name, record_id, preloaded_image[0].width, preloaded_image[0].height
	document.getElementById(id).value = "";

#--------------------------------------------------------------------------------------------------
window.upload_main_performer_photo = (e) ->
	existing_file_ids = []
	input = $(event.currentTarget)
	id = input.attr("id")
	readers = []
	model_name = "performers"
	for file in input[0].files
		file_id = window.makeid(7)
		template_name = "img_thumb"
		fast_preview = HandlebarsTemplates[template_name]({"data-model": model_name, src: "/assets/images/thumb_dumb.gif", attachment_comment: file.name, id: file_id})
		$(window.upload_preview_selector).html(fast_preview)
		o = new FileReader()
		o.file_id = file_id
		o.file = file
		o.readAsDataURL file
		o.onload = (e) -> #Загружено с диска в память браузера
			image_base64 = e.target.result
			image_hash = sha512(image_base64)
			preview = HandlebarsTemplates[template_name]({"data-model": model_name, src: image_base64, thumb: image_base64, attachment_comment: @file.name, id: @file_id, image_hash: image_hash})
			pic_real_width = undefined
			pic_scaled_width = undefined
			pic_real_height = undefined
			pic_scaled_height = 200
			preloaded_image = $("<img id='#{@file_id}'/>")
			preloaded_image.file_id = @file_id
			preloaded_image.load( ->
				preloaded_image_id = $(this)[0].id
				$("##{preloaded_image_id}").replaceWith(preview)
				pic_real_width = @width
				pic_real_height = @height
				pic_scaled_width = pic_real_width * (pic_scaled_height / pic_real_height)
				$("##{preloaded_image_id} img").css
					width: "#{pic_scaled_width}px"
					height: "#{pic_scaled_height}px"
				return
			).attr("src", image_base64)
			record_id = window.get_parent_record_id()
			window.upload @file, @file_id, image_hash, model_name, record_id, preloaded_image[0].width, preloaded_image[0].height
	document.getElementById(id).value = "";

#--------------------------------------------------------------------------------------------------
window.render_face_squares = (params, data) ->
	res = params.res
#	window.if_console res: res
	img = $(".popup img")
	window.squares = []
	window.original_image_filename = res.original_image_filename
	window.original_image_width = res.original_image_width
	window.original_image_height = res.original_image_height
	window.pic_width = parseInt(img.css("width"))
	window.pic_height = parseInt(img.css("height"))
	window.kx = window.pic_width / window.original_image_width
	window.ky = window.pic_height / window.original_image_height
#	window.if_console "window.pic_width": window.pic_width, "window.original_image_width": window.original_image_width, "window.kx": window.kx
	window.result_avatar_height = $(window.result_avatar_selector).height()
	window.kmed = Math.sqrt(window.kx * window.ky)
	window.padding = parseInt($(".popup").css("padding"))
	window.k = window.pic_width / window.pic_height
	window.selected_square_index = 0
	if res.faces.length > 0
		for face, index in res.faces
			window.squares.push {
				top: face.top
				left: face.left
				diameter: face.diameter
			}
			$(".popup").append("<div id='face-round-#{index}' draggable='true'></div>")
			window.set_square_style(index)
			if index == window.selected_square_index
				window.set_result_square(index)
	else
		diameter = 100 + window.padding * 4
		window.squares.push {
			top: 100
			left: 100
			diameter: diameter
		}
		$(".popup").append("<div id='face-round-0' draggable='true'></div>")
		window.set_square_style(0)
		window.set_result_square(0)

#--------------------------------------------------------------------------------------------------
document.ondragstart = (e) ->
	e.dataTransfer.setData 'index', index_from_str(e.target.id)
	e.dataTransfer.setData 'mouse_x', e.clientX
	e.dataTransfer.setData 'mouse_y', e.clientY

#--------------------------------------------------------------------------------------------------
document.ondragover = (e) ->
	e.preventDefault()

#--------------------------------------------------------------------------------------------------
#document.ondragend = (e) ->
#	window.if_console e.target.id

#--------------------------------------------------------------------------------------------------
document.ondrop = (e) ->
	index = e.dataTransfer.getData("index")
	old_mouse_x = parseInt(e.dataTransfer.getData("mouse_x"))
	old_mouse_y = parseInt(e.dataTransfer.getData("mouse_y"))
	square = $("#face-round-#{index}")
	img = $(".popup img")
	index = index_from_str($(square).attr("id"))
	window.squares[index].top = window.squares[index].top + (e.clientY - old_mouse_y) / window.kx
	window.squares[index].left = window.squares[index].left + (e.clientX - old_mouse_x) / window.ky
	window.selected_square_index = index
	window.set_square_style(index)
	window.set_result_square(index)

#--------------------------------------------------------------------------------------------------
window.set_result_square = (index) ->
	selected_square = $(".popup #face-round-#{index}")
	for square in $(".popup [id^='face-round-']")
		$(square).css
			"background-color": "transparent"
	selected_square.css
		"background-color": "white"
		"opacity": "0.2"
	selected_square_height = selected_square.height()
	selected_square_left = parseInt(selected_square.css(window.left_attr)) - window.padding
	selected_square_top = parseInt(selected_square.css(window.top_attr)) - window.padding
	background_of_result_avatar_height = window.pic_height / selected_square_height * window.result_avatar_height
	background_of_result_avatar_width = background_of_result_avatar_height * window.k
	background_position_left = [0, -1 * selected_square_left * (window.result_avatar_height / selected_square_height)].min()
	background_position_top = [0, -1 * selected_square_top * (window.result_avatar_height / selected_square_height)].min()
	window.set_style window.result_avatar_selector, [
		["background-image", "url(#{$('.popup img').attr('src')})"]
		["background-position", "#{background_position_left}px #{background_position_top}px"]
		["background-size", "#{background_of_result_avatar_width}px #{background_of_result_avatar_height}px"]
	]

#--------------------------------------------------------------------------------------------------
window.set_square_style = (index) ->
	square = $(".popup #face-round-#{index}")
	diameter = window.squares[index].diameter
	top = window.squares[index].top
	left = window.squares[index].left
#	window.if_console "diameter": diameter, top: top, left: left
	square.css
		width: "#{diameter * window.kx}px"
		height: "#{diameter * window.ky}px"
		top: "#{top * window.ky + window.padding}px"
		left: "#{left * window.kx + window.padding}px"
		"border-radius": "#{diameter * window.kmed / 2}px"
		"-webkit-border-radius": "#{diameter * window.kmed / 2}px"
		"-moz-border-radius": "#{diameter * window.kmed / 2}px"

#--------------------------------------------------------------------------------------------------
$(document).click (e) ->
	if /reduce/.test e.target.className
		window.on_reduce_click(e)
	if /increase/.test e.target.className
		window.on_increase_click(e)
	if /^face-round-\d+/.test e.target.id
		window.on_face_round_click(e)
	if /^btn-avatar-confirm$/.test e.target.id
		window.confirm_avatar()

#--------------------------------------------------------------------------------------------------
window.confirm_avatar = ->
	window.get_ajax "/set_avatar", {
		original_image: 
			filename: window.original_image_filename
			width: window.original_image_width
			height: window.original_image_height
		scaled_image:
			width: window.pic_width
			height: window.pic_height
			padding: window.padding
		selected:
			top: window.squares[window.selected_square_index].top
			left: window.squares[window.selected_square_index].left
			diameter: window.squares[window.selected_square_index].diameter
	}, set_avatar

#--------------------------------------------------------------------------------------------------
set_avatar = (data, params) ->
#	$("[id^='face-round-'").remove()
#	$(".avatar-control").remove()
	$(".popup").remove()
	$(".back-stage").remove()
#	window.if_console data: data, params: params
	$("#devise-client-avatar").remove()
	$("#upload-performer-avatar").before("<div id='devise-client-avatar'></div>")
	background_position_left = 0
	background_position_top = 0
	background_of_result_avatar_width = 100
	background_of_result_avatar_height = 100
	window.set_style "#devise-client-avatar", [
		["background-image", "url(http://#{window.location.hostname}/#{data.avatar_image_file_name}?)"]
		["background-position", "#{background_position_left}px #{background_position_top}px"]
		["background-size", "#{background_of_result_avatar_width}px #{background_of_result_avatar_height}px"]
		["width", "#{background_of_result_avatar_width}px"]
		["height", "#{background_of_result_avatar_height}px"]
		["border-radius", "#{background_of_result_avatar_width / 2}px"]
		["-webkit-border-radius", "#{background_of_result_avatar_width / 2}px"]
		["-moz-border-radius", "#{background_of_result_avatar_width / 2}px"]
		["cursor", "pointer"]
	]

#--------------------------------------------------------------------------------------------------
index_from_str = (str) ->
	parseInt(str.match(/\d+/)) 

#--------------------------------------------------------------------------------------------------
window.on_face_round_click = (e) ->
	index = index_from_str(e.target.id)
	if index == window.selected_square_index
		window.confirm_avatar()
	else
		window.set_result_square(index)
		window.selected_square_index = index

#--------------------------------------------------------------------------------------------------
window.on_reduce_click = (e) ->
	index = window.selected_square_index
	window.squares[index].diameter = window.squares[index].diameter * 0.9
	window.set_square_style index
	window.set_result_square(index)

#--------------------------------------------------------------------------------------------------
window.on_increase_click = (e) ->
	index = window.selected_square_index
	window.squares[index].diameter = window.squares[index].diameter / 0.9
	window.set_square_style index
	window.set_result_square(index)

#--------------------------------------------------------------------------------------------------
window.onUploadSuccess = (e, bar_id) ->
#	window.if_console "window.onUploadSuccess = (e, #{bar_id}) ->"
#	window.if_console e
	$("##{bar_id} progress").css
		opacity: 0;
	attachment_id = $('.attachment').attr('id')
	attachment_filename = JSON.parse(e.responseText)["filename"]
	$("##{bar_id} img").attr
		src: "/#{attachment_filename}"
	if $("#upload-performer-avatar").length > 0
		window.get_ajax "/fcd", {picture: attachment_filename}, window.render_face_squares, {}
	
#-- upload error listener -------------------------------------------------------------------------
window.onUploadError = (e) ->
#	window.if_console "error"
#	window.if_console e

#-- draw progressbar on uploaded image preview ----------------------------------------------------
window.onUploadProgress = (loaded, total, bar_id) ->
#	window.if_console "window.onUploadProgress = (#{loaded}, #{total}, #{bar_id}) ->"
	$("##{bar_id} progress").attr("value", "#{loaded / total * 100}")
	$("##{bar_id} progress").css
		display: "block"

#-- Upload one file to host ---------------------------------------------------------------------
window.upload = (file, bar_id, attachment_hash, model_name, record_id, image_width, image_height) ->
#	window.if_console
#		file: file
#		bar_id: bar_id
#		attachment_hash: attachment_hash
	unless record_id
#		window.if_console "unless record_id"
		window.status_body "error", HandlebarsTemplates[wrong_id_template](), 7
		return
	xhr = new XMLHttpRequest()
	xhr.onload = xhr.onerror = ->
		if @status isnt 200
			window.onUploadError(this)
			return
		window.onUploadSuccess(this, bar_id)
		return

	xhr.upload.onprogress = (event) ->
		window.onUploadProgress(event.loaded, event.total, bar_id)
		return
	image_sizes = "&image_width=#{image_width}&image_height=#{image_height}"
#	window.if_console bar_id: bar_id, event: event, attachment_hash: attachment_hash, model_name: model_name, record_id: record_id
	window.save_master(record_id)
	xhr.open "POST", "/upload_something?file_name=#{file.name}&attachment_hash=#{attachment_hash}&attachmentable_type=#{model_name}&attachmentable_id=#{record_id}#{image_sizes}", true
	xhr.setRequestHeader('X-CSRF-Token', window.get_token())
	xhr.send file

#--------------------------------------------------------------------------------------------------
window.save_master = (id) ->
	unless id
#		window.if_console "unless id"
		window.status_body "error", HandlebarsTemplates[wrong_id_template](), 7

#--------------------------------------------------------------------------------------------------
window.set_page_sign = (sign_string) ->
	$(window.content_selector).attr("data-page-sign", sign_string)

#--------------------------------------------------------------------------------------------------
window.get_page_sign = ->
	$(window.content_selector).attr("data-page-sign")