class Track::Trophies::General::CompletedAllExercisesTrophy < Track::Trophy
  def name(_) = "Completionist"
  def icon = 'trophy-completed-all-exercises'

  def criteria(track)
    "Awarded once you complete all exercises in %<track_title>s" % { track_title: track.title }
  end

  def success_message(track)
    "Congratulations on completing all exercises in %<track_title>s" % { track_title: track.title }
  end

  def award?(user, track)
    UserTrack.for(user, track).completed?
  end

  def send_email_on_acquisition? = true
end
