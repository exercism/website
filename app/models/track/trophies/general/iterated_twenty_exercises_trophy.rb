class Track::Trophies::General::IteratedTwentyExercisesTrophy < Track::Trophy
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
    Solution.joins(:exercise).
      where(user:, exercise: { track: }).
      where('num_iterations >= 2').
      count >= NUM_EXERCISES
  end

  def self.worth_queuing?(iteration:, **_context)
    iteration.idx > 1
  end

  def send_email_on_acquisition? = true

  NUM_EXERCISES = 20
  private_constant :NUM_EXERCISES
end
