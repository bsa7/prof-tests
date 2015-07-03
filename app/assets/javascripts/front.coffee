#--------------------------------------------------------------------------------------------------
$(document).click (e) ->
	window.document_onclick(e)

#--------------------------------------------------------------------------------------------------
window.document_onclick = (e) ->
	if $(e.target).data("ajax") == 1
		if $(e.target).data("type") == "answer_variant"
			question_id = $(e.target).data("question-id")
			answer_id = $(e.target).data("answer-id")
			window.get_ajax("/check_answer",
				session_id: window.session_identify()
				question_id: question_id
				answer_id: answer_id
				question_list: $("#question-list").data("question-list")
			, check_answer)
	if /btn-fancy-close/.test(e.target.className)
		$(".fancybox-opened").remove()
		$(".fancybox-overlay").remove()
	if /btn-next/.test(e.target.className)
		window.next_question()

#--------------------------------------------------------------------------------------------------
window.next_question = ->
	window.get_ajax(window.location.pathname, 
		layout: false
		session_id: window.session_identify()
		question_list: $("#question-list").data("question-list")
	, render_question)

#--------------------------------------------------------------------------------------------------
check_answer = (data, params) ->

	if data.is_right
		window.status_body "success", "<div class='vm'><div class='center'>Правильный ответ !</div></div>", 1
		#$("#resume").html("<div class='vm bggreen'><div class='center'>Правильный ответ !</div></div><div class='mt30 btn btn-next'>Далее</div>")			
		window.next_question()			
	else
		#window.dialog "<h2>#{data.question}</h2><h2 class='c1'>Ваш ответ:</h2>#{data.your_answer}<h1 class='cred'>Неправильный ответ.</h1><h2>Правильный ответ:</h2><p class='cgreen'>#{data.right_answer}</p><div class='btn btn-fancy-close'>Закрыть</div>"
		$("#resume").html("<h2 class='c0'>Ваш ответ:</h2><p class='c1'>#{data.your_answer}</p><h1 class='cred'>Неправильный ответ.</h1><h2>Правильный ответ:</h2><p class='c1'>#{data.right_answer}</p><div class='mt30 btn btn-next'>Далее</div>")			

#--------------------------------------------------------------------------------------------------
render_question = (data, params) ->
	$("#content").html(data)
	question_answered_count = parseInt($('#question-list').data("question-count")) - parseInt($('#question-list').data("question-left"))
	$("#counter").html("#{question_answered_count} / #{$('#question-list').data("question-count")}")

#--------------------------------------------------------------------------------------------------
window.session_identify = ->
	if !window.varCache("cliend_id").v
		window.varCache("cliend_id", window.makeid(133))
	window.varCache("cliend_id").v

#--------------------------------------------------------------------------------------------------
$ ->
	window.front_doc_ready()

#--------------------------------------------------------------------------------------------------
window.front_doc_ready = ->
	window.if_console(window.session_identify())