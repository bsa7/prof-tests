class TestingController < ApplicationController

	before_action :client_identify

	#---------------------------------------------------------------------------------------------
	def show
		Utils.d params_show: params, session: @session
		dir = "#{Rails.root}/public/tests/#{params['test_type'].gsub(/-/,'_')}"
		params["question_list"] = "" if !params["question_list"]
		@question = Utils.get_next_question(dir, params['session_id'], params["question_list"].split(',').map(&:to_i))
		@question[:stat] = round_stat(@session[:session_id])
		respond_to do |format|
			format.html{ render( "testing/show", layout: Utils.need_layout(params))}
		end
	end

	#---------------------------------------------------------------------------------------------
	def check
		Utils.d params_check: params, session: @session
		right_answer_id = RightAnswer.where(question_id: params["question_id"]).first.answer_id
		answer_status = params["answer_id"] == right_answer_id
		right_answer_text = AnswerVariant.where(question_id: params["question_id"], answer_id: right_answer_id).first.text
		your_answer_text = AnswerVariant.where(question_id: params["question_id"], answer_id: params["answer_id"]).first.text
		client_id = client_shortcut_id(@session[:client_id])
		session_id = session_shortcut_id(@session[:session_id])
		client_answer = ClientAnswer.new(
			client_shortcut_id: client_id,
			session_shortcut_id: session_id,
			question_id: params["question_id"],
			answer_id: params["answer_id"],
			is_right: answer_status
		)
		client_answer.save!
		render json: {
			is_right: answer_status,
			right_answer: right_answer_text,
			your_answer: your_answer_text,
			question: Question.find(params["question_id"]).text}
	end

	private
	#---------------------------------------------------------------------------------------------
	def client_identify
		@session = {
			client_id: params["client_id"],
			session_id: params["authenticity_token"],
			client_name: Utils.client_name(params["client_id"])
		}
	end

	#---------------------------------------------------------------------------------------------
	def client_shortcut_id(id)
		if id
			client_shortcut = ClientShortcut.where(client_id: id)
			if client_shortcut.size == 0
				client_shortcut = ClientShortcut.new(client_id: id, ip: request.remote_ip)
				client_shortcut.save!
				client_shortcut.id
			else
				client_shortcut.first.id
			end
		else
			nil
		end
	end

	#---------------------------------------------------------------------------------------------
	def session_shortcut_id(id)
		if id
			session_shortcut = SessionShortcut.where(session_id: id)
			if session_shortcut.size == 0
				session_shortcut = SessionShortcut.new(session_id: id)
				session_shortcut.save!
				session_shortcut.id
			else
				session_shortcut.first.id
			end
		else
			nil
		end
	end

	#---------------------------------------------------------------------------------------------
	def round_stat(session_id)
		session_shortcut = session_shortcut_id(session_id)
		client_answers = ClientAnswer.where(session_shortcut_id: session_shortcut)
		stat = {
			right_answer_count: 0,
			total_answer_count: 0,
			total_time: 0
		}
		if client_answers.size > 0
			stat[:right_answer_count] = client_answers.where(is_right: 1).size
			stat[:total_answer_count] = client_answers.size
			stat[:total_time] = client_answers.pluck(:created_at).max - client_answers.pluck(:created_at).min
		end
		stat
	end

end
