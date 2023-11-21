class TrainingData::ExternalController < ApplicationController
  skip_before_action :authenticate_user!, except: :become_trainer

  def index
    redirect_to training_data_root_path if current_user&.trainer?

    @eligible = current_user&.eligible_for_trainer?
    @max_reputation_track = current_user && current_user.user_tracks.order(reputation: :desc).first
  end

  def become_trainer
    User::BecomeTrainer.(current_user)

    redirect_to training_data_root_path
  end
end
