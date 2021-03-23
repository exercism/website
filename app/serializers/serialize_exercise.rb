class SerializeExercise
  include Mandate

  def initialize(exercise, user_track: nil)
    @exercise = exercise
    @user_track = user_track
  end

  def call
    {
      slug: exercise.slug,
      title: exercise.title,
      icon_url: exercise.icon_url,
      difficulty: "easy", # TOOD
      blurb: exercise.blurb,
      is_available: available?,
      is_recommended: recommended?,
      is_completed: user_track ? user_track.exercise_completed?(exercise) : nil,
      links: links
    }
  end

  private
  attr_reader :exercise, :user_track

  def available?
    user_track ? user_track.exercise_available?(exercise) : nil
  end

  def recommended?
    false # TODO
  end

  def links
    return {} unless available?

    {
      self: Exercism::Routes.track_exercise_path(exercise.track, exercise)
    }
  end
end
