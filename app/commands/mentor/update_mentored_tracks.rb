class Mentor::UpdateMentoredTracks
  include Mandate

  initialize_with :mentor, :tracks

  def call
    mentor.update!(mentored_tracks: tracks)
  end
end
