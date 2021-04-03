class SerializeExercise
  include Mandate

  def initialize(exercise, user_track: nil)
    @exercise = exercise
    @user_track = user_track || UserTrack::External.new(nil)
  end

  def call
    {
      slug: exercise.slug,
      title: exercise.title,
      icon_url: exercise.icon_url,
      difficulty: "easy", # TOOD
      blurb: exercise.blurb,
      is_external: user_track.external?,
      is_unlocked: unlocked?,
      is_recommended: recommended?,
      is_completed: user_track.exercise_completed?(exercise),
      links: links
    }
  end

  private
  attr_reader :exercise, :user_track

  def unlocked?
    user_track.exercise_unlocked?(exercise)
  end

  def recommended?
    return false if user_track.external?

    false
  end

  def links
    return {} unless unlocked?

    {
      self: Exercism::Routes.track_exercise_path(exercise.track, exercise)
    }
  end
end
