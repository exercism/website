class Mentor::UpdateMentoredTracks
  include Mandate

  initialize_with :mentor, :tracks

  def call
    mentor.update!(mentored_tracks: tracks)
    User::UpdateSupermentorRole.defer(mentor)
  end
end
