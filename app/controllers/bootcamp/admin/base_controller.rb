class Bootcamp::Admin::BaseController < Bootcamp::BaseController
  before_action :authenticate_admin!

  private
  def authenticate_admin!
    return if current_user.admin?

    redirect_to root_path, alert: "You are not authorized to access this page."
  end
end
