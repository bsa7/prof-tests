require 'colorize'
require 'utils'

task :load_tests => :environment do
	available_test_list = []
	test_source_dir = "#{Rails.root}/public/tests"
	Dir.entries(test_source_dir).each do |entry|
		next if entry[/^\./]
		available_test_list << entry
	end
	print "Очистка предыдущих данных"

	Rake::Task["db:drop"].invoke
	Rake::Task["db:create"].invoke
	Rake::Task["db:migrate"].invoke

	print "Доступные тесты: \n".yellow
	ActiveRecord::Base.transaction do
		available_test_list.each do |test_dir|
			dir = "#{test_source_dir}/#{test_dir}"
			print "#{dir}\n"
			existing_test_names = TestName.where(load_dir: test_dir)
			if existing_test_names.size == 0
				test_names = TestName.new
				test_names.update_attributes!(load_dir: test_dir, name: test_dir)
				test_name_id = test_names.id
			else
				test_name_id = existing_test_names.first.id
			end
			question_file = File.open("#{dir}/questions.txt").read
			questions = []
			question_file.each_line do |line|
				if line[/^\d+\.\s/]
					questions << {text: line.gsub(/^\d+\.\s*/,'').chomp}
				else
					answer_variant_key = line[/^[А-ЯЁ]/]
					questions.last[answer_variant_key] = line.gsub(/^[А-ЯЁ]\)\s*/,'')
				end
			end
			print "Доступно вопросов: #{questions.size}".green
			answers_file = File.open("#{dir}/answers.txt").read
			question_index = 0
			answers_file.each_line do |line|
				questions[question_index][:right_answer] = line.chomp
				question_index += 1
			end
			questions.each_with_index do |question, index|
				#Utils.d question: question[:text]
				print "Вопрос №#{index}: #{question[:text]} - ".yellow
				print "записан\n".green
				question_rec = Question.new(text: question[:text], test_name_id: test_name_id)
				question_rec.save!
				question_id = question_rec.id

				question.keys.each do |key|
					next if key.class == Symbol
					#Utils.d answer: question[key]
					if AnswerVariant.where(question_id: question_id, text: question[key]).size == 0
						answer_variant = AnswerVariant.new(answer_id: key, text: question[key], question_id: question_id)
						answer_variant.save!
					end
				end

				if RightAnswer.where(question_id: question_id).size == 0
					right_answer = RightAnswer.new(question_id: question_id, answer_id: question[:right_answer])
					right_answer.save!
				end

			end
		end
	end
end

