class Track::Trophies::General::CompletedTwentyExercisesTrophy < Track::Trophies::GeneralTrophy
  def name(_) = "Twenty"
  def icon = 'trophy-completed-twenty-exercises'

  def criteria(track)
    "Awarded once you complete %<num_completed_exercises> exercises in %<track_title>s" % {
      num_completed_exercises: NUM_COMPLETED_EXERCISES,
      track_title: track
    }
  end

  def success_message(track)
    "Congratulations on completing %<num_completed_exercises> exercises in %<track_title>s" % {
      num_completed_exercises: NUM_COMPLETED_EXERCISES,
      track_title: track
    }
  end

  def award?(user_track) = user_track.num_completed_exercises >= NUM_COMPLETED_EXERCISES

  NUM_COMPLETED_EXERCISES = 20
  private_constant :NUM_COMPLETED_EXERCISES
end
