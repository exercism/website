class ProfilesController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[show tooltip]
  before_action :use_profile

  def show
    raise ActiveRecord::RecordNotFound unless @profile

    @badges = @user.badges
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
