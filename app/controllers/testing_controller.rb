class TestingController < ApplicationController

	#- repeat background rendering for some image -----------------------------------
	def show
		dir = "#{Rails.root}/public/tests/#{params['test_type'].gsub(/-/,'_')}"
		@question = Utils.get_questions(dir)
	end

end
