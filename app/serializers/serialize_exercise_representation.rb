class SerializeExerciseRepresentation
  include Mandate

  initialize_with :representation

  delegate :exercise, :track, to: :representation

  def call
    {
      id: representation.id,
      exercise: {
        icon_url: exercise.icon_url,
        title: exercise.title
      },
      track: {
        icon_url: track.icon_url,
        title: track.title
      },
      num_submissions: representation.num_submissions,
      feedback_html: representation.feedback_html,
      last_submitted_at: representation.last_submitted_at,
      links: {
        # TODO: link to edit page
        # self: Exercism::Routes.track_exercise_path(exercise.track, exercise)
      }
    }
  end
end
