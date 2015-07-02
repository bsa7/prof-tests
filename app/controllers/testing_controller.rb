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
		right_answer_text = "right_answer_text"
		render json: {is_right: answer_status, right_answer: right_answer_text}
	end

end
