#--------------------------------------------------------------------------------------------------
$(document).click (e) ->
	window.document_onclick(e)

#--------------------------------------------------------------------------------------------------
window.document_onclick = (e) ->
	if $(e.target).data("ajax") == 1
		if $(e.target).data("type") == "answer_variant"
			question_id = $(e.target).data("question-id")
			answer_id = $(e.target).data("answer-id")
			window.status_body "info", HandlebarsTemplates["info"](message: "Ответ принят..."), 0
			#сообщаем серверу id клиента (params["client_id"]), а id сессии известен и так, как params["authenticity_token"]
			window.get_ajax("/check_answer",
				client_id: window.client_identify()
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
		client_id: window.client_identify()
		question_list: $("#question-list").data("question-list")
	, render_question)

#--------------------------------------------------------------------------------------------------
check_answer = (data, params) ->

	window.close_status()
	if data.is_right
		window.status_body "success", HandlebarsTemplates['right_answer'], 3
		window.next_question()			
	else
		window.status_body "error", HandlebarsTemplates['wrong_answer']
			your_answer: data.your_answer
			right_answer: data.right_answer

#--------------------------------------------------------------------------------------------------
render_question = (data, params) ->
	window.close_status()
	$("#content").html(data)
	question_answered_count = parseInt($('#question-list').data("question-count")) - parseInt($('#question-list').data("question-left"))
	total_answer_count = parseInt($('#question-list').data("total-answers-count"))
	right_answer_count = parseInt($('#question-list').data("right-answers-count"))
	wrong_answer_count = total_answer_count - right_answer_count
	time_for_answers = parseFloat($('#question-list').data("time-for-answers"))
	question_count = $('#question-list').data('question-count')
	#$("#counter").html("#{question_answered_count}(<p class='ib'>#{wrong_anwsers_count}</p> / <p class='ib'>#{right_answer_count}</p>) из #{question_count} вопросов")
#	$("#system-progress-bar > #wrong").css
#		width: "#{window.getWindowSize().width * wrong_anwsers_count / question_count}px"
#	$("#system-progress-bar > #right").css
#		width: "#{window.getWindowSize().width * right_anwsers_count / question_count}px"
#	window.if_console "wrong width": "#{window.getWindowSize().width * wrong_answer_count / question_count}px", "right width": "#{window.getWindowSize().width * right_answer_count / question_count}px"
	window.set_style("#system-progress-bar > #wrong", [["width", "#{window.getWindowSize().width * wrong_answer_count / question_count}px"]])
	window.set_style("#system-progress-bar > #right", [["width", "#{window.getWindowSize().width * right_answer_count / question_count}px"]])


#--------------------------------------------------------------------------------------------------
window.client_identify = ->
	if !window.varCache("cliend_id").v
		window.varCache("cliend_id", window.makeid(133))
	window.varCache("cliend_id").v

#--------------------------------------------------------------------------------------------------
$ ->
	window.front_doc_ready()

#--------------------------------------------------------------------------------------------------
window.front_doc_ready = ->
	window.if_console window.client_identify()