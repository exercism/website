class SerializeExercises
  include Mandate

  def initialize(exercises, user_track: nil)
    @exercises = exercises
    @user_track = user_track
  end

  def call
    any_recommended = false
    exercises.map do |exercise|
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

  private
  attr_reader :exercises, :user_track
end
