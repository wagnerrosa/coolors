class ColorsController < ApplicationController
	before_action :find_color, only: [:show, :edit, :update, :destroy, :vote_up]
	before_action :authenticate_user!, except: [:index, :show]
	before_action :admin_user_logged?, only: [:edit, :update, :destroy]
	before_action :voteup_time, only: [:vote_up]

	def index
		@colors = Color.all.order("created_at desc")
	end

	def new
		@color = Color.new
	end

	def create
		@color = Color.new color_params

		if @color.save
			redirect_to @color, notice: "Nice Cool Color! It was successfully created"
		else
			render 'new', notice: "Oh no! Could you try again?"
		end

	end

	def show
	end

	def edit
	end

	def update
		if @color.update color_params
			redirect_to @color, notice: "Yeah! Updated!"
		else		
			render 'edit'
		end
	end

	def destroy
		@color.destroy
		redirect_to colors_path, notice: "Color deleted... You're right, that wasn't so cool!"
	end

	def vote_up
		if @color.update_attributes(:updated_at => DateTime.now)
			begin
				current_user.vote_for(@color)
				redirect_to :back, notice: "Thanks for voting"
			rescue ActionController::RedirectBackError
				redirect_to root_path
			end			
		end
	end

	private

	def color_params
		params.require(:color).permit(:color1, :color2, :color3)
	end

	def find_color
		@color = Color.find(params[:id])		
	end

	def admin_user_logged?
		#if current_user.admin?
		if current_user.id === 2 # adminn account Heroku
			#faz nada
		else
			redirect_to root_path
		end
	end

	def voteup_time
		old_date = @color.updated_at_was
		if old_date > (DateTime.now - 1.minutes)
			redirect_to :back, notice: "You already voted!"
		end
		rescue ActionController::RedirectBackError
  		redirect_to root_path		
	end
end
