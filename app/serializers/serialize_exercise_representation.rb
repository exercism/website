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
      appears_frequently: representation.appears_frequently?,
      feedback_markdown: representation.feedback_markdown,
      feedback_type: representation.feedback_type.to_s,
      last_submitted_at: representation.last_submitted_at,
      files: SerializeFiles.(representation.source_submission.files_for_editor),
      instructions: Markdown::Parse.(representation.solution.instructions),
      tests: representation.solution.tests,
      links: {
        self: Exercism::Routes.edit_mentoring_automation_path(representation),
        update: Exercism::Routes.api_mentoring_representation_path(representation)
      }
    }
  end
end
