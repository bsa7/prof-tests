require 'colorize'
require 'unicode'

wrong_answers_count = 0
total_answers_count = 0
question_file = File.open('questions.txt').read
questions = []
question_file.each_line do |line|
	if line[/^\d+\.\s/]
		questions << {text: line.gsub(/^\d+\.\s*/,'')}
	else
		answer_variant_key = line[/^[А-ЯЁ]/]
		questions.last[answer_variant_key] = line.gsub(/^[А-ЯЁ]\)\s*/,'')
	end
end

answers_file = File.open('answers.txt').read
question_index = 0
answers_file.each_line do |line|
	questions[question_index][:right_answer] = line.chomp
	question_index += 1
end

print "Всего вопросов: #{questions.size}\n".green

a=true

questions.shuffle.each do |question|
	print "#{'-'*88}\n".cyan
	print "Всего вопросов:"
	print " #{total_answers_count}".yellow
	print " из "
	print "#{questions.size}\n".yellow
	if total_answers_count > 0
		print "% правильных ответов: #{((total_answers_count.to_f - wrong_answers_count) / total_answers_count * 100).to_i}%\n".green
	end
	print "#{question[:text].gsub(/\s\s+/, ' ')}".yellow
	print "#{'='*88}\n".yellow
#	print question.keys.inspect
	answer_variants = question.keys.reject{|x|x.class == Symbol}
	answer_sorted = answer_variants.each_with_index.map{|x,i|[i+1, x]}
	answer_shuffled = answer_sorted.shuffle.each_with_index.map{|x,i|[i+1, x[1], x[0]]}
	answer_shuffled.each do |key|
		print "#{key[0]}: #{question[key[1]].gsub(/\s\s+/, ' ')}\n"
	end
#	answer_variants_sorted = 
#	answer_variants = answer_variants.map{|x|[]}
	answer_received = false
	break_test = false
	while !answer_received do
		print "Введите цифру правильного ответа (#{answer_shuffled.map{|x|x[0]}.sort.join(' ')}): "
		answer_attempt = gets.chomp
		if !answer_shuffled.map{|x|x[0]}.include?(answer_attempt.to_i)
			print "Вы хотите продолжать (Д/н)".red
			continue_answer = gets.chomp
			if continue_answer == "Д"
				next
			else
				answer_received = true
				break_test = true
			end
		else
			answer_received = true
		end
	end
	#Сравнение с ответами
	total_answers_count += 1
	right_answer = answer_shuffled.each_with_object({}){|a, x|x[a[1]] = a[0]}[question[:right_answer].upcase]
	#answer_attempt = answer_shuffled[answer_attempt.to_i - 1][1]
#	print "answer_attempt: '#{answer_attempt}', right_answer: '#{right_answer}'"
	if answer_attempt.to_i == right_answer.to_i
		print "\nПравильный ответ!\n\n\n\n".green
	else
		wrong_answers_count += 1
		print "\nНеправильный ответ!\n\n\n\n".red
		print "Правильный ответ: #{right_answer} - #{question[question[:right_answer].upcase]}\n\n".cyan
	end
	a = !break_test
end