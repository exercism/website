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
    includes = [:track]

    if exercises.is_a?(Array)
      Exercise.where(id: exercises.map(&:id)).includes(includes)
    else
      exercises.includes(includes)
    end
  end
end
