class Track::Trophies::Shared::CompletedFiveDifficultExercisesTrophy < Track::Trophies::SharedTrophy
  def name(_) = "Difficult"
  def icon = 'trophy-completed-five-difficult-exercises'

  def criteria(track)
    "Awarded once you complete %<num_exercises>i difficult exercises in %<track_title>s" % {
      num_exercises: NUM_EXERCISES,
      track_title: track
    }
  end

  def success_message(track)
    "Congratulations on completing %<num_exercises>i difficult exercises in %<track_title>s" % {
      num_exercises: NUM_EXERCISES,
      track_title: track
    }
  end

  def award?(user_track) = user_track.completed?

  NUM_EXERCISES = 5
  private_constant :NUM_EXERCISES
end
