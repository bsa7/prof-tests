require 'colorize'
require 'utils'

task :load_tests => :environment do
  available_test_list = []
  test_source_dir = "#{Rails.root}/public/tests"
  Dir.entries(test_source_dir).each do |entry|
    next if entry[/^\./]
    available_test_list << entry
  end
# print "Очистка предыдущих данных"

# Rake::Task["db:drop"].invoke
# Rake::Task["db:create"].invoke
# Rake::Task["db:migrate"].invoke

  print "Доступные тесты: \n".yellow
  ActiveRecord::Base.transaction do
    available_test_list.each do |test_dir|
      dir = "#{test_source_dir}/#{test_dir}"
      print "#{dir}\n"
      e_hash = {load_dir: test_dir, name: test_dir}
      existing_test_names = TestName.where(e_hash)
      if existing_test_names.size == 0
        test_names = TestName.new(e_hash)
        test_names.save!
        test_name_id = test_names.id
      else
        test_name_id = existing_test_names.first.id
      end
      question_file = File.open("#{dir}/questions.txt").read
      questions = []
      right_answers = []
      answers_file_name = "#{dir}/answers.txt"
      if File.exist?(answers_file_name)
        answers_file = File.open(answers_file_name).read
        question_index = 0
        answers_file.each_line do |line|
          right_answers.push(line.chomp)
          question_index += 1
        end
      end
      question_file.each_line do |line|
        if line[/^\d+\.\s/]
          questions << {text: line.gsub(/^\d+\.\s*/,'').chomp, }
        else
          answer_variant_key = line[/^[А-ЯЁ]/]
          questions.last[answer_variant_key] = line.gsub(/^[А-ЯЁ]\)\s*/,'')
          if right_answers.present?
            questions.last[:right_answer] = right_answers[questions.length - 1]
          else
            questions.last[:right_answer] = "А"
          end
        end
      end
      print "Доступно вопросов: #{questions.size}".green
      puts "\nДоступно ответов в отдельном файле: #{right_answers.length.to_s.yellow}\n"
      question_rec = nil
      Rails.logger.ap questions: questions[0..2]
      questions.each_with_index do |question, question_index|
        #Utils.d question: question[:text]
        print "Вопрос №#{question_index}: #{question[:text]} - ".yellow
        print "записан\n".green
        q_hash = {text: question[:text], test_name_id: test_name_id}
        question_id = nil
        if Question.where(q_hash).count == 0
          question_rec = Question.new(q_hash)
          question_rec.save!
          question_id = question_rec.id
        else
          question_id = Question.where(q_hash).first.id
#          next
        end

        question.keys.each do |key|
          Rails.logger.ap key: key, question_id: question_id, question: question
          next if key.class == Symbol
          #Utils.d answer: question[key]
          if AnswerVariant.where(question_id: question_id, text: question[key]).count == 0
            answer_variant = AnswerVariant.new(answer_id: key, text: question[key], question_id: question_id)
            answer_variant.save!
          end
        end

        existed_right_answers = RightAnswer.where(question_id: question_id)
        if existed_right_answers.count == 0
          right_answer = RightAnswer.new(question_id: question_id, answer_id: question[:right_answer])
          right_answer.save!
        else
          right_answer = existed_right_answers.first.update_attributes!(question_id: question_id, answer_id: question[:right_answer])
          #right_answer.save!
        end
      end
    end
  end
end

