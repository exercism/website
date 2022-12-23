class UserTrack::Destroy
  include Mandate

  initialize_with :user_track

  def call
    UserTrack::Reset.(user_track)
    user_track.destroy
  end
end
