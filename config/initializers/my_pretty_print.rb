require 'colorize'

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
							$result << "\n#{indent}\"#{key.to_s.cyan}\": "
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
class Hash
	include MyPrettyPrint
end

#---------------------------------------------------------------------------------
class Array
	include MyPrettyPrint
end

