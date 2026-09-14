class ColorsController < ApplicationController
  before_action :find_color, only: [ :show, :edit, :update, :destroy, :vote_up ]
  before_action :authenticate_user!, except: [ :index, :show, :trend, :vote_up ]
  before_action :admin_user_logged?, only: [ :edit, :update, :destroy ]

  def index
    @colors = Color.order(created_at: :desc)
  end

  def trend
    @colors = Color.order(votes_count: :desc, created_at: :desc)
  end

  def show
  end

  def new
    @color = Color.new
  end

  def create
    @color = Color.new color_params

    if @color.save
      redirect_to @color, notice: "Nice Cool Color! It was successfully created"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @color.update color_params
      redirect_to @color, notice: "Yeah! Updated!"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @color.destroy
    redirect_to colors_path, notice: "Color deleted... You're right, that wasn't so cool!"
  end

  # Anonymous voting: one vote per visitor per color, enforced by a unique
  # index on [color_id, voter_key]. The 2016 version called current_user.vote_for
  # here while allowing logged-out access, so it always raised NoMethodError.
  def vote_up
    @color.votes.create!(voter_key: voter_key)
    redirect_back fallback_location: root_path, notice: "Thanks for voting"
  rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotUnique
    redirect_back fallback_location: root_path, alert: "You already voted!"
  end

  private

  def color_params
    params.require(:color).permit(:color1, :color2, :color3)
  end

  def find_color
    @color = Color.find(params[:id])
  end

  def admin_user_logged?
    redirect_to(root_path) unless current_user&.admin?
  end

  # Signed cookie for anonymous visitors; stable id once signed in.
  def voter_key
    return "user:#{current_user.id}" if user_signed_in?

    cookies.signed[:voter_key] ||= {
      value: SecureRandom.uuid,
      expires: 1.year.from_now,
      httponly: true
    }
    cookies.signed[:voter_key]
  end
end
