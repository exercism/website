class TrainingData::ExternalController < ApplicationController
  skip_before_action :authenticate_user!

  def index
    redirect_to training_data_root_path if current_user&.trainer?
  end
end
