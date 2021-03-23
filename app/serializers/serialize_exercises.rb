class SerializeExercises
  include Mandate

  def initialize(exercises, user_track: nil)
    @exercises = exercises
    @user_track = user_track
  end

  def call
    exercises.map { |exercise| SerializeExercise.(exercise, user_track: user_track) }
  end

  private
  attr_reader :exercises, :user_track
end
