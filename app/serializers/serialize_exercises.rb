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

    return exercises.includes(includes) if exercises.is_a?(ActiveRecord::Relation)

    ids = exercises.map(&:id)

    Exercise.where(id: ids).
      order(Arel.sql("FIND_IN_SET(id, '#{ids.join(',')}')")).
      includes(includes)
  end
end
