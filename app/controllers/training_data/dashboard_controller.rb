class TrainingData::DashboardController < ApplicationController
  skip_before_action :authenticate_user!
  before_action :ensure_trainer!

  def index
    redirect_to training_data_code_tags_samples_path
  end
end
