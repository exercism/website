class SerializeBootcampExercise
  include Mandate

  initialize_with :exercise

  def call
    return unless exercise

    {
      slug: exercise.slug,
      title: exercise.title,
      description: exercise.description,
      project: {
        slug: exercise.project.slug,
        title: exercise.project.title,
        description: exercise.project.description
      }
    }
  end
end
