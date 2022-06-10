class UserTrack
  class Reset
    include Mandate

    initialize_with :user_track
    delegate :user, :track, to: :user_track

    def call
      user_track.solutions.update_all("user_id = #{User::GHOST_USER_ID}, unique_key = UUID()")
      user_track.update(
        anonymous_during_mentoring: false,
        last_touched_at: Time.current,
        objectives: nil
      )
      user_track.reset_summary!
      User::ReputationTokens::PublishedSolutionToken.where(user:, track:).destroy_all
    end
  end
end
