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
	if /btn-fancy-close/.test(e.target.className)
		$(".fancybox-opened").remove()
		$(".fancybox-overlay").remove()

#--------------------------------------------------------------------------------------------------
check_answer = (data, params) ->
	if data.is_right
		window.status_body "success", "<div class='vm'><div class='center'>Правильный ответ !</div></div>", 1
	else
		window.dialog "<h2>#{data.question}</h2><h2 class='c1'>Ваш ответ:</h2>#{data.your_answer}<h1 class='cred'>Неправильный ответ.</h1><h2>Правильный ответ:</h2><p class='cgreen'>#{data.right_answer}</p><div class='btn btn-fancy-close'>Закрыть</div>"
	window.get_ajax(window.location.pathname, {layout: false}, render_question)

#--------------------------------------------------------------------------------------------------
render_question = (data, params) ->
	$("#content").html(data)