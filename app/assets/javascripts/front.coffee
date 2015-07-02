#--------------------------------------------------------------------------------------------------
$(document).click (e) ->
	window.document_onclick(e)

#--------------------------------------------------------------------------------------------------
window.document_onclick = (e) ->
	if $(e.target).data("ajax") == 1
		if $(e.target).data("type") == "answer_variant"
			question_id = $(e.target).data("question-id")
			answer_id = $(e.target).data("answer-id")
			#window.get_ajax = (url, data_adds, callback = null, callback_params = null, async = true, query_type = "GET", datatype = "json") ->
			window.get_ajax("/check_answer", {question_id: question_id, answer_id: answer_id}, check_answer)

#--------------------------------------------------------------------------------------------------
check_answer = (data, params) ->
	if data.is_right
		window.status_body "success", "Правильный ответ", 1
	else
		window.status_body "error", "Неправильный ответ", 1
	window.get_ajax(window.location.pathname, {layout: false}, render_question)

#--------------------------------------------------------------------------------------------------
render_question = (data, params) ->
	$("#content").html(data)