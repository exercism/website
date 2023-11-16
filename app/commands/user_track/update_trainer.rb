class UserTrack::UpdateTrainer
  include Mandate

  initialize_with :user_track

  def call = user_track.update!(trainer:)

  private
  def trainer = user_track.reputation >= User::MIN_REP_TO_TRAIN_ML
end
