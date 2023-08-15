class Track::Trophies::General::CompletedTwentyExercisesTrophy < Track::Trophy
  def name(_) = "Prolific Padawan"
  def icon = 'trophy-completed-twenty-exercises'
  def order = 1

  def criteria(track)
    "Awarded once you complete %<num_completed_exercises>i exercises in %<track_title>s" % {
      num_completed_exercises: NUM_COMPLETED_EXERCISES,
      track_title: track.title
    }
  end

  def success_message(track)
    "Congratulations on completing %<num_completed_exercises>i exercises in %<track_title>s" % {
      num_completed_exercises: NUM_COMPLETED_EXERCISES,
      track_title: track.title
    }
  end

  def award?(user, track)
    UserTrack.for(user, track).num_completed_exercises >= NUM_COMPLETED_EXERCISES
  end

  def send_email_on_acquisition? = true

  NUM_COMPLETED_EXERCISES = 20
  private_constant :NUM_COMPLETED_EXERCISES
end
