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
        slug: project.slug,
        title: project.title,
        description: project.description
      },
      solve_url: Exercism::Routes.edit_bootcamp_project_exercise_path(project, exercise)
    }
  end

  delegate :project, to: :exercise
end
