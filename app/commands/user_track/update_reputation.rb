class UserTrack::UpdateReputation
  include Mandate

  initialize_with :user_track

  def call = user_track.update!(reputation:)

  private
  def reputation
    User::ReputationToken.where(
      track: user_track.track,
      user_id: user_track.user_id
    ).sum(:value)
  end
end
