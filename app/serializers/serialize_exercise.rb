class SerializeExercise
  include Mandate

  def initialize(exercise, user_track: nil, recommended: false)
    @exercise = exercise
    @user_track = user_track || UserTrack::External.new(nil)
    @recommended = recommended
  end

  def call
    {
      slug: exercise.slug,
      type: exercise.tutorial? ? "tutorial" : exercise.git_type,
      title: exercise.title,
      icon_url: exercise.icon_url,
      difficulty: exercise.difficulty_category,
      blurb: exercise.blurb,
      is_external: user_track.external?,
      is_unlocked: unlocked?,
      is_recommended: recommended?,
      links:
    }
  end

  private
  attr_reader :exercise, :user_track, :recommended

  def unlocked?
    user_track.exercise_unlocked?(exercise)
  end

  def recommended?
    return false if user_track.external?

    recommended
  end

  def links
    {
      self: Exercism::Routes.track_exercise_path(exercise.track, exercise)
    }
  end
end
