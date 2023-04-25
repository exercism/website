class Admin::DashboardController < Admin::BaseController
  before_action :ensure_staff!

  # GET /admin
  def show; end
end
