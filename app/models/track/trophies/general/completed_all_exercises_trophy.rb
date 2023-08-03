class Track::Trophies::General::CompletedAllExercisesTrophy < Track::Trophies::GeneralTrophy
  def name(_) = "Completionist"
  def icon = 'trophy-completed-all-exercises'

  def criteria(track)
    "Awarded once you complete all exercises in %<track_title>s" % { track_title: track }
  end

  def success_message(track)
    "Congratulations on completing all exercises in %<track_title>s" % { track_title: track }
  end

  def award?(user_track) = user_track.completed?
end
