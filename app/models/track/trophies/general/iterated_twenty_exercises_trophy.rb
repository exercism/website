class Track::Trophies::General::IteratedTwentyExercisesTrophy < Track::Trophies::GeneralTrophy
  def name(_) = "Iterator"
  def icon = 'trophy-iterated-twenty-exercises'

  def criteria(track)
    "Awarded once you submit multiple iterations for %<num_exercises> exercises in %<track_title>s" % {
      num_exercises: NUM_EXERCISES,
      track_title: track
    }
  end

  def success_message(track)
    "Congratulations on submitting multiple iterations for %<num_exercises> exercises in %<track_title>s" % {
      num_exercises: NUM_EXERCISES,
      track_title: track
    }
  end

  def award?(user, track)
    user.solutions.joins(:exercise).
      where(exercise: { track: }).
      where('num_iterations >= 2').
      count >= NUM_EXERCISES
  end

  NUM_EXERCISES = 20
  private_constant :NUM_EXERCISES
end
