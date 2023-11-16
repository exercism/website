class UserTrack::ToggleTrainer
  include Mandate

  initialize_with :user_track, :enable

  def call
    raise TrainerCriteriaNotFulfilledError if enable && user_track.reputation < User::MIN_REP_TO_TRAIN_ML

    user_track.update!(trainer: enable)
  end
end
