require 'colorize'
#require 'RMagick'
#include Magick

module Utils

	#----------------------------------------------------------------------------------------------------
	def  self.client_name(client_id)
		client = Client.where(client_id: client_id)
		if client.size > 0
			client.first.nick
		else
			nil
		end
	end

	#----------------------------------------------------------------------------------------------------
	def self.get_next_question(dirname, session_id, question_list = nil)
#		Utils.d session_id: session_id, question_list: question_list
		question = {}
		testname = dirname[/[^\/]+$/].gsub(/-/, '_')
		testname_id = TestName.where(load_dir: testname)
		question[:count] = Question.where(test_name_id: testname_id).pluck(:id).size
		if question_list.size == 0
			question_list = Question.where(test_name_id: testname_id).pluck(:id)
		end
		question[:list] = question_list
		question_id = question_list.sample
		question[:id] = question_id
		question[:text] = Question.find(question_id).text
		answer_variant_list = AnswerVariant.where(question_id: question_id).pluck(:id)
		question[:answers] = {}
		answer_variant_list.each do |answer_variant_id|
			answer_variant = AnswerVariant.find(answer_variant_id)
			question[:answers][answer_variant.answer_id] = answer_variant.text
		end
		question
	end

	#----------------------------------------------------------------------------------------------------
	def self.create_css_rules(sizes, style_selector, rules)
		rule_stub = "<rules>"
		size_stub = "<size>"
		rules_result = ""
		sizes.each do |size|
			rule_template = "#{style_selector.sub(size_stub, "#{size}")}{#{rule_stub}}"
			[rules].flatten.each do |rule|
				rule_template.sub!(rule_stub, rule.gsub(size_stub, "#{size}") + rule_stub)
			end
			rules_result << rule_template.sub(rule_stub, "")
		end
		rules_result
	end

	#----------------------------------------------------------------------------------------------------
	def self.datetime_names
		{shortDayNames: I18n.t("date.abbr_day_names"),
		  fullDayNames: I18n.t("date.day_names"),
		  shortMonthNames: I18n.t("date.abbr_month_names")[1..-1],
		  fullMonthNames: I18n.t("date.month_names")[1..-1],
		  clearButtonContent: I18n.t("main.datetime_picker.clear_button_content"),
		  setButtonContent: I18n.t("main.datetime_picker.set_button_content"),
		  titleContentDate: I18n.t("main.datetime_picker.title_content_date"),
		  titleContentTime: I18n.t("main.datetime_picker.title_content_time"),
		  titleContentDateTime: I18n.t("main.datetime_picker.title_content_date_time")}
	end

	#----------------------------------------------------------------------------------------------------
	def self.default_collapse
		"1"
	end

	#----------------------------------------------------------------------------------------------------
	def self.current_timestamp
		(Time.now.to_f*1000).to_i
	end

	#----------------------------------------------------------------------------------------------------
	def self.current_datetime
		Time.now
	end

	#----------------------------------------------------------------------------------------------------
	def self.controller_name
		params[:controller]
	end

	#- detect if no layout needed in render --------------------------------------------------------------------------
	def self.need_layout params
		if params && params[:layout] && params[:layout].to_s == "false"
			false
		else
			true
		end
	end

	#- backend logger --------------------------------------------------------------------------------
	def self.d *params
		puts params.my_pretty_print
		Rails.logger.debug "\n\n\n= debug start: "+"="*88
		Rails.logger.debug params.my_pretty_print
		Rails.logger.debug "= debug end ==="+"="*88+"\n\n\n"
	end

	#- detect attachment type --------------------------------------------------------------------------------
	def self.detect_attachment_type filename
		unless filename
#			Utils.d filename, file_ext
		end
		file_ext = filename[/(?<=\.)[^\.]+$/]
		file_ext = file_ext ? file_ext.downcase : "extension not defined"
		if %w(jpeg jpg png gif bmp tiff).include? file_ext
			1 #image
		else
			2 #undefined
		end
	end

	#--------------------------------------------------------------------------------------------------
	def self.numberWithCommas x
		parts = x.to_s.split(".")
		parts[0] = parts[0].gsub(/\B(?=(\d{3})+(?!\d))/, " ")
		parts.join "."
	end

	#- detect class of attachment image-------------------------------------------------------------------
	def self.wide_or_tall attachment
		if attachment.width && attachment.height
			attachment.width > attachment.height ? "wide" : "tall"
		else
			"wide"
		end
	end

	#- attachment filename with path ---------------------------------------------------------------------
	def self.attachment_filename filename
		"#{Rails.root}/public/system/uploads/#{filename}"
	end

	#- full url to image --------------------------------------------------------------------------------------
	def self.url filename
		"/system/uploads/#{filename.split(/\//)[-2..-1].join('/')}"
	end

end

$result = ""
#---------------------------------------------------------------------------------
module MyPrettyPrint
 
	#---------------------------------------------------------------------------------
	def pp_ah(value, indent, is_last = false)
		comma_sign = is_last ? '' : ','
		case value.class.to_s
			when "Array", "Hash", "ActionController::Parameters"
				value.my_pretty_print indent: indent, recursive: true
				$result << comma_sign
			when "String"
				$result << "#{'"'.white}#{value.yellow}#{'"'.white}#{comma_sign}"
			else
				$result << "#{value.to_s.yellow}#{comma_sign}"
		end
	end
 
#---------------------------------------------------------------------------------
	def my_pretty_print params = {}
		if !params[:recursive]
			$result = ""
		end
		indent = params[:indent] || ""
		selector = params[:selector]
		if selector
			case selector.class.to_s
				when "Range"
					case self.class.to_s
						when "Hash", "ActionController::Parameters"
							the_self = {}
							self.keys[selector].each do |key|
								the_self[key] = self[key]
							end
						when "Array"
							the_self = self[selector]
					end
				when "Symbol"
					the_self = self[selector] ? {selector => self[selector]} : nil
				when "String"
					the_self = self[selector] ? {selector => self[selector]} : nil
				when "Fixnum"
					case self.class.to_s
						when "Hash"
							the_self = {self.keys[selector] => self[self.keys[selector]]}
						when "Array"
							the_self = self[selector]
					end
			end
		else
			the_self = self
		end
 
		case the_self.class.to_s
			when "Hash", "ActionController::Parameters"
				last_key_index = the_self.keys.size - 1
				$result << "{".white
				the_self.each_with_index do |(key, value), index|
					case key.class.to_s
						when "String"
							$result << "\n#{indent}\"#{key.to_s.cyan}\" => "
						when "Symbol"
							$result << "\n#{indent}#{key.to_s.cyan}: "
					end
					pp_ah value, indent+'  ', index == last_key_index
				end
				$result << "\n#{indent[0..-3]}}".white
			when "Array"
				last_key_index = the_self.size - 1
				$result << "[\n".white
				the_self.each_with_index do |value, index|
					$result << indent
					pp_ah value, indent+'  ', index == last_key_index
					if the_self.last != value
						$result << "\n"
					end
				end
				$result << "\n#{indent[0..-3]}]".white
			else
		end
	end
	$result
end

#---------------------------------------------------------------------------------
module Conversations
  def to_obj
    self.each do |k,v|
      if v.kind_of? Hash
        v.to_obj
      end
      k=k.to_s.gsub(/\.|\s|-|\/|\'/, '_').downcase.to_sym
      ## create and initialize an instance variable for this key/value pair
      self.instance_variable_set("@#{k}", v)
      ## create the getter that returns the instance variable
      self.class.send(:define_method, k, proc{self.instance_variable_get("@#{k}")})
      ## create the setter that sets the instance variable
      self.class.send(:define_method, "#{k}=", proc{|v| self.instance_variable_set("@#{k}", v)})
    end
    return self
  end
end
 
#---------------------------------------------------------------------------------
class Hash
	include MyPrettyPrint
	include Conversations
end
 
#---------------------------------------------------------------------------------
class Array
	include MyPrettyPrint
end

