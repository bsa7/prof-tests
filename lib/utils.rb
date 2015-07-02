require 'colorize'
require 'RMagick'
include Magick

class Utils

	#----------------------------------------------------------------------------------------------------
	def self.get_questions(dirname)
		
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
	def self.video_source src
		if src[/youtu.?be/]
			video_code = src[/\b[a-zA-Z0-9]{11}\b/]
			"class=performer-video src=https://www.youtube.com/embed/#{video_code} frameborder=0 allowfullscreen=true"
		else
			video_id = src[/\d+$/]
			"class=performer-video output=embed src=http://player.vimeo.com/video/#{video_id} frameborder=0 webkitallowfullscreen=true mozallowfullscreen=true allowfullscreen=true"
		end
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
			Utils.d filename, file_ext
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

	#- add watermark to image ----------------------------------------------------------------------------
	def self.add_watermark destImageFileName
		#add a watermark
		watermark_file_name = "#{Dir.pwd}/public/assets/images/watermark_thumbh120.png"
		watermark_image = Magick::Image.read(watermark_file_name).first
		image = Magick::Image.read(destImageFileName).first
		proportion = image.columns.to_f / image.rows.to_f
#		Utils.d proportion
		if proportion > 1.61 # изображение шире, чем 1.61 : 1, будет выравниваться по высоте с 
			image.composite( watermark_image, image.columns - watermark_image.columns - 20, image.columns / 1.61 - watermark_image.rows - 20, OverCompositeOp).write(destImageFileName)
		else # изображение уже, чем 1.61 : 1
			image.composite( watermark_image, image.columns - watermark_image.columns - 20, image.rows - watermark_image.rows - 20, OverCompositeOp).write(destImageFileName)
		end
	end

	#- name of background image -------------------------------------------------------------------------------
	def self.bg_name filename
		if filename[/_thumbh360/]
			filename.gsub(/_thumbh360\.([^\.]+)$/, '_bg.jpg')
		else
			filename.gsub(/\.([^\.]+)$/, '_bg.jpg')
		end
	end

	#- full url to image --------------------------------------------------------------------------------------
	def self.url filename
		"/system/uploads/#{filename.split(/\//)[-2..-1].join('/')}"
	end

	#- create filename for thumbnail image -------------------------------------------------------------------
	def self.thumb_name filename, thumb_size
		filename.gsub(/(\..+?)$/,"_thumbh#{thumb_size}.jpg")
	end

	#- create thumbnails of image - convert any foramt to jpeg -------------------------------------------------
	def self.create_thumbnails srcFileName
#		Utils.d "create_thumbs: #{srcFileName}".yellow
		destimg = Magick::Image::read(srcFileName).first
		image_width = destimg.columns.to_f
		image_height = destimg.rows.to_f
		thumbMaxHeights = ThumbType.all.pluck(:size)
		thumbWidths = thumbMaxHeights.map{|thumbMaxHeight| image_width * thumbMaxHeight / image_height}
		thumbMaxHeights.each_with_index do |thumbMaxHeight, i|
			thumbWidth = thumbWidths[i]
#			thumbFileName = srcFileName.gsub(/(\..+?)$/,"_thumbh#{thumbMaxHeight}.jpg")
			thumbFileName = Utils.thumb_name srcFileName, thumbMaxHeight
#			unless File.exists? thumbFileName
#				Utils.d thumbFileName.green
				destimg.scale(thumbWidth, thumbMaxHeight).write thumbFileName do
					self.format = 'JPEG'
					self.quality = 50
				end
				#add a watermark
				#Utils.add_watermark thumbFileName
#			end
		end
	end

	#-----------------------------------------------------------------------------------------------------------------
	def self.img_full_name srcFileName
		"#{Rails.root}/public#{Utils.url(srcFileName)}"
	end

	#-----------------------------------------------------------------------------------------------------------------
	def self.face_detect srcFileName
		require 'opencv'
		include OpenCV

		#Utils.d srcFileName: srcFileName
		data = '/home/slon/distr/opencv-2.4.10/data/haarcascades/haarcascade_frontalface_alt.xml'
		detector = CvHaarClassifierCascade::load(data)
		#сначала определимся, большое ли это изображение и, если что используем его уменьшенную копию ..._thumb360...
		original_image_filename = srcFileName
		srcFileName = Utils.img_full_name srcFileName
		originalImage = CvMat.load(srcFileName)
#		original_image_width = originalImage.width
#		original_image_height = originalImage.height
		unless srcFileName[/_thumb360/]
			Utils.create_thumbnails srcFileName
			thumbFileName = Utils.thumb_name srcFileName, 360
		end
		thumbImage = CvMat.load(thumbFileName)
		kx = (thumbImage.width.to_f / originalImage.width).to_f
		ky = (thumbImage.height.to_f / originalImage.height).to_f
		#Utils.d kx: kx, ky: ky, "thumbImage.width": thumbImage.width, "thumbImage.height": thumbImage.height, "originalImage.width": originalImage.width, "originalImage.height": originalImage.height
		results = {
			image_width: thumbImage.width,
			image_height: thumbImage.height,
			original_image_width: originalImage.width,
			original_image_height: originalImage.height,
			original_image_filename: original_image_filename,
			faces: []
		}
		padding = 150
		detector.detect_objects(thumbImage).each do |region|
			results[:faces] << {
				diameter: ((region.width + region.height) / 2) / kx + padding * 4,
				top: region.top_left.y / ky - padding * 2,
				left: region.top_left.x / kx - padding * 2
			}
		end
		results
	end
	
	#- create background of image - add left and right field for tall and top && bottom fields fow wide aspect ratios -
	def self.create_background destFileName
#		Utils.d "create_background: #{destFileName}".yellow
		destimg = Magick::Image::read(destFileName).first
		image_width = destimg.columns.to_f
		image_height = destimg.rows.to_f
		bgFileName = destFileName.gsub(/(\..+?)$/,"_bg.jpg")
		bgHeight = 360
		aspect_ratio = 1.4235294117647058823529411764706
		bgWidth = bgHeight * aspect_ratio
		thumb_image_str = destimg.to_blob do
			self.quality = 10
		end
		bg_image = Image.from_blob(thumb_image_str)[0]
		thumb_image = Image.from_blob(thumb_image_str)[0]
		field_images = Magick::ImageList.new
		if image_width > image_height #wide image - add top and bottom fields to background image
			thumb_image = thumb_image.resize(bgWidth, bgHeight * 100)
			field_images << thumb_image.crop(0, 0, bgWidth, bgHeight / 2) #top field
			field_images << thumb_image.crop(0, bgHeight * 100 - bgHeight / 2, bgWidth, bgHeight/2) #bottom_field
			bg_image = field_images.append(true) #glue top to bottom
		else #tall image - add left and right fields to background image
			thumb_image = thumb_image.resize(bgWidth * 100, bgHeight)
			field_images << thumb_image.crop(0, 0, bgWidth/2, bgHeight) #left field
			field_images << thumb_image.crop(bgWidth * 100 - bgWidth / 2, 0, bgWidth/2, bgHeight) #right field
			bg_image = field_images.append(false) #glue left to right
		end
		bg_image.gaussian_blur(10.0, 13.0).write bgFileName do
			self.format = 'JPEG'
			self.quality = 30
		end
		field_images.destroy!
		bg_image.destroy!
		thumb_image.destroy!
		free_memory_size = %x(free).split(" ")[9].to_i
		if free_memory_size < 3000000
			puts "Garbage collection".cyan
			GC.start
		else
			puts "Free memory: #{free_memory_size}".green
		end
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

