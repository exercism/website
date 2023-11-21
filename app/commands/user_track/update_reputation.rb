class UserTrack::UpdateReputation
  include Mandate

  queue_as :reputation

  initialize_with :user_track

  def call = user_track.update!(reputation:)

  private
  def reputation
    User::ReputationToken.where(
      track_id: user_track.track_id,
      user_id: user_track.user_id
    ).sum(:value)
  end
end
