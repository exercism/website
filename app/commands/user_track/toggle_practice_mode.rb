class UserTrack::TogglePracticeMode
  include Mandate

  initialize_with :user_track, :enabled

  def call
    @user_track.update!(
      practice_mode: enabled,
      last_touched_at: Time.current
    )
    @user_track.reset_summary!
    @user_track.save!
  end
end
