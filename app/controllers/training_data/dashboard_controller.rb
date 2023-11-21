class TrainingData::DashboardController < ApplicationController
  before_action :ensure_trainer!

  def index
    @training_data_dashboard_params = params.permit(:status, :order, :criteria, :page, :track_slug)
    @statuses = %w[needs_tagging needs_checking needs_checking_admin]
  end
end
