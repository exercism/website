class Track::Trophies::General::CompletedFiftyPercentOfExercisesTrophy < Track::Trophy
  def name(_) = "Laudable Learner"
  def icon = 'trophy-completed-fifty-percent-of-exercises'
  def order = 2

  def criteria(track)
    "Awarded once you complete %<percentage_completed_exercises>i%% of the exercises in %<track_title>s" % {
      percentage_completed_exercises: PERCENTAGE_COMPLETED_EXERCISES,
      track_title: track.title
    }
  end

  def success_message(track)
    "Congratulations on completing %<percentage_completed_exercises>i%% of the exercises in %<track_title>s" % {
      percentage_completed_exercises: PERCENTAGE_COMPLETED_EXERCISES,
      track_title: track.title
    }
  end

  def award?(user, track)
    UserTrack.for(user, track).completed_percentage >= PERCENTAGE_COMPLETED_EXERCISES
  end

  def send_email_on_acquisition? = true

  PERCENTAGE_COMPLETED_EXERCISES = 50
  private_constant :PERCENTAGE_COMPLETED_EXERCISES
end
