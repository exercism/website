class TrainingData::DashboardController < ApplicationController
  before_action :guard_trainer!, except: :become_trainer

  def index
    @training_data_dashboard_params = params.permit(:status, :order, :criteria, :page, :track_slug)
    @statuses = %w[needs_tagging needs_checking needs_checking_admin]
  end

  def become_trainer
    User::BecomeTrainer.(current_user) unless current_user.trainer?

    redirect_to training_data_root_path if current_user.trainer?
  end

  def guard_trainer!
    return true if current_user&.trainer?

    redirect_to training_data_external_path
  end
end
