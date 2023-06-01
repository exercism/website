class SerializeExercises
  include Mandate

  initialize_with :exercises, user_track: nil

  def call
    any_recommended = false
    eager_loaded_exercises.map do |exercise|
      if !any_recommended && %w[available started].include?(user_track&.exercise_status(exercise))
        any_recommended = true
        recommended = true
      end

      SerializeExercise.(
        exercise,
        user_track:,
        recommended: !!recommended
      )
    end
  end

  def eager_loaded_exercises
    exercises.to_active_relation.includes(:track)
  end
end
