class Track::Trophies::General::CompletedFiftyPercentOfExercisesTrophy < Track::Trophy
  def name(_) = "Halfway There"
  def icon = 'trophy-completed-fifty-percent-of-exercises'

  def criteria(track)
    "Awarded once you complete %<percentage_completed_exercises>i of the exercises in %<track_title>s" % {
      percentage_completed_exercises: PERCENTAGE_COMPLETED_EXERCISES,
      track_title: track
    }
  end

  def success_message(track)
    "Congratulations on completing %<percentage_completed_exercises>i of the exercises in %<track_title>s" % {
      percentage_completed_exercises: PERCENTAGE_COMPLETED_EXERCISES,
      track_title: track
    }
  end

  def award?(user, track)
    UserTrack.for!(user, track).completed_percentage >= 50.0
  end

  PERCENTAGE_COMPLETED_EXERCISES = 20
  private_constant :PERCENTAGE_COMPLETED_EXERCISES
end
