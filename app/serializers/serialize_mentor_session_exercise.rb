class SerializeMentorSessionExercise
  include Mandate

  initialize_with :exercise

  def call
    {
      slug: exercise.slug,
      title: exercise.title,
      icon_url: exercise.icon_url,
      links: {
        self: Exercism::Routes.track_exercise_path(exercise.track, exercise)
      }
    }
  end
end
