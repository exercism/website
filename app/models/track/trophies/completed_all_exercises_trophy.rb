class Track::Trophies::CompletedAllExercisesTrophy < Track::Trophy
  def name(_) = "Exemplary Expert"
  def icon = 'trophy-completed-all-exercises'
  def order = 6

  def criteria(track)
    "Awarded once you complete the whole %<track_title>s Track" % { track_title: track.title }
  end

  def success_message(track)
    "WOW! Congratulations on completing the %<track_title>s Track! Incredible work!" % { track_title: track.title }
  end

  def award?(user, track)
    UserTrack.for(user, track).completed?
  end
end
