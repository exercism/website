class TrainingData::ExternalController < ApplicationController
  skip_before_action :authenticate_user!

  def index
    redirect_to training_data_root_path if current_user&.trainer?

    @eligible = current_user.eligible_for_trainer?
    @max_reputation_track = current_user.user_tracks.order(reputation: :desc).first
  end
end
