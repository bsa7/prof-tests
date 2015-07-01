require 'colorize'
require 'unicode'
require 'terminfo'


screen_sizes = TermInfo.screen_size
screen_width = screen_sizes[1]
wrong_answers_count = 0
total_answers_count = 0


print "Есть два варианта билетов:\n".yellow
print "#{'='*screen_width}\n".yellow
print "1. Сосуды, работающие под давлением\n"
print "2. Трубопроводы пара и горячей воды\n"
print "Введите ваш выбор (1 2) "

tests_type = gets.chomp

if tests_type == "1"
	dir = "/home/slon/projects/tests/public/tests/pressure_vessels/"
elsif tests_type == "2"
	dir = "/home/slon/projects/tests/public/tests/pipelines_of_steam_and_hot_water/"
end

#print dir+"questions.txt\n"

question_file = File.open(dir+'questions.txt').read
questions = []
question_file.each_line do |line|
	if line[/^\d+\.\s/]
		questions << {text: line.gsub(/^\d+\.\s*/,'')}
	else
		answer_variant_key = line[/^[А-ЯЁ]/]
		questions.last[answer_variant_key] = line.gsub(/^[А-ЯЁ]\)\s*/,'')
	end
end

#print questions.inspect

answers_file = File.open(dir+'answers.txt').read
question_index = 0
answers_file.each_line do |line|
#	print "#{question_index}(#{questions[question_index]}): #{line}".green
	questions[question_index][:right_answer] = line.chomp
	question_index += 1
end


print "Всего вопросов: #{questions.size}\n".green

a=true

questions.shuffle.each do |question|
	print "#{'-'*screen_width}\n".cyan
	print "Вопрос:"
	print " #{total_answers_count + 1}".yellow
	print " из "
	print "#{questions.size}".yellow
 print "(#{total_answers_count - wrong_answers_count}".green
 print "/"
 print "#{wrong_answers_count})\n".red
	if total_answers_count > 0
		print "% правильных ответов: #{((total_answers_count.to_f - wrong_answers_count) / total_answers_count * 100).to_i}%\n".green
	end
	print "#{question[:text].gsub(/\s\s+/, ' ')}".yellow
	print "#{'='*screen_width}\n".yellow
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