class UsersController < ApplicationController

	# POST /users
	def index
		# /users?act=login
		if params[:act] == 'login'
			render 'login'
		end
	end

	# POST /:userid
	def show
		
	end
end
