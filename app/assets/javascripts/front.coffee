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
		window.dialog "<div class='vm'><div class='center'>Правильный ответ !</div></div>"
	else
		window.dialog "<h2>#{data.question}</h2><h2>Ваш ответ:</h2>#{data.your_answer}<h1 class='c1'>Неправильный ответ.</h1><h2>Правильный ответ:</h2>#{data.right_answer}"
	window.get_ajax(window.location.pathname, {layout: false}, render_question)

#--------------------------------------------------------------------------------------------------
render_question = (data, params) ->
	$("#content").html(data)