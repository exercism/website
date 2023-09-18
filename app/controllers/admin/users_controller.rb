class Admin::UsersController < Admin::BaseController
  # GET /admin/users
  def index; end

  # GET /admin/users/search
  def search
    @user = params[:email].present? ? User.find_by(email: params[:email]) : nil
    @searched = params[:email].present?
  end
end
