class Track::Trophies::IteratedTwentyExercisesTrophy < Track::Trophy
  def name(_) = "Persistent Perfectionist"
  def icon = 'trophy-iterated-twenty-exercises'
  def order = 3

  # rubocop:disable Layout/LineLength
  def criteria(track)
    "Awarded for submitting multiple iterations in %<num_exercises>i exercises" % {
      num_exercises: NUM_EXERCISES,
      track_title: track.title
    }
  end

  def success_message(track)
    "Congratulations on submitting multiple iterations for %<num_exercises>i exercises in %<track_title>s. Keep on refining your knowledge!" % {
      num_exercises: NUM_EXERCISES,
      track_title: track.title
    }
  end
  # rubocop:enable Layout/LineLength

  def award?(user, track)
    Solution.joins(:exercise).
      where(user:, exercise: { track: }).
      where('num_iterations >= 2').
      count >= NUM_EXERCISES
  end

  def worth_queuing?(**context)
    return true unless context.key?(:iteration)

    context[:iteration].idx > 1
  end

  NUM_EXERCISES = 20
  private_constant :NUM_EXERCISES
end
