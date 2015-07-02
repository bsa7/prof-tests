class TestingController < ApplicationController

	#- repeat background rendering for some image -----------------------------------
	def show
		dir = "#{Rails.root}/public/tests/#{params['test_type'].gsub(/-/,'_')}"
		@question = Utils.get_next_question(dir)
		respond_to do |format|
			format.html{ render( "testing/show", layout: Utils.need_layout(params))}
		end

	end

	def check
		Utils.d params: params
		right_answer_id = RightAnswer.where(question_id: params["question_id"]).first.answer_id
		answer_status = params["answer_id"] == right_answer_id
		right_answer_text = AnswerVariant.where(question_id: params["question_id"], answer_id: right_answer_id).first.text
		your_answer_text = AnswerVariant.where(question_id: params["question_id"], answer_id: params["answer_id"]).first.text
		render json: {
			is_right: answer_status,
			right_answer: right_answer_text,
			your_answer: your_answer_text,
			question: Question.find(params["question_id"]).text}
	end

end
