class Track::UpdateNumExercises
  include Mandate

  initialize_with :track

  def call
    filtered_exercises = track.exercises.where(status: %i[active beta])
    filtered_exercises = filtered_exercises.where(type: PracticeExercise.to_s) unless track.course?

    track.update_column(:num_exercises, filtered_exercises.count)
  end
end
