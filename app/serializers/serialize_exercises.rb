class SerializeExercises
  include Mandate

  def initialize(exercises, user_track: nil)
    @exercises = exercises
    @user_track = user_track
  end

  def call
    exercises.map do |exercise|
      {
        slug: exercise.slug,
        title: exercise.title,
        icon_url: exercise.icon_url,
        blurb: exercise.blurb,
        available: user_track ? user_track.exercise_available?(exercise) : nil
      }
    end
  end

  private
  attr_reader :exercises, :user_track
end
