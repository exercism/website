class ProfilesController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[show tooltip]
  before_action :use_profile

  def show
    raise ActiveRecord::RecordNotFound unless @profile

    # TODO: Order all these by most prominent first
    @badges = @user.badges
    @solutions = @user.solutions.published.first(3)
    @testimonials = @user.mentor_testimonials.published.first(3)

    @num_total_solutions = @user.solutions.published.count
    @num_testimonials = @user.mentor_testimonials.count
  end

  def tooltip
    expires_in 1.minute

    render layout: false
  end

  private
  def use_profile
    @user = User.find_by(handle: params[:id])
    @profile = @user.profile
  end
end
