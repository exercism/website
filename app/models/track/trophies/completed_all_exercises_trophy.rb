class Track::Trophies::CompletedAllExercisesTrophy < Track::Trophy
  def name(_) = "Exemplary Expert"
  def icon = 'trophy-completed-all-exercises'
  def order = 6

  def criteria(track)
    "Awarded once you complete all exercises in %<track_title>s" % { track_title: track.title }
  end

  def success_message(track)
    "Congratulations on completing all exercises in %<track_title>s" % { track_title: track.title }
  end

  def award?(user, track)
    UserTrack.for(user, track).completed?
  end
end
