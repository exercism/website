class Track::Trophies::CompletedFiftyPercentOfExercisesTrophy < Track::Trophy
  def name(_) = "Laudable Learner"
  def icon = 'trophy-completed-fifty-percent-of-exercises'
  def order = 2

  def criteria(track)
    "Awarded once you complete 50%% of the exercises in %<track_title>s" % {
      track_title: track.title
    }
  end

  def success_message(track)
    "Congratulations on getting half way there and completing 50%% of the exercises in %<track_title>s" % {
      track_title: track.title
    }
  end

  def award?(user, track)
    UserTrack.for(user, track).completed_percentage >= 50
  end
end
