class HomeController < ApplicationController
	def index
		render "home/index", layout: Utils.need_layout(params)
	end
end
