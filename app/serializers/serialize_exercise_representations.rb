class SerializeExerciseRepresentations
  include Mandate

  initialize_with :representations, params: Mandate::NO_DEFAULT

  def call
    eager_loaded_representations.
      map { |representation| SerializeRepresentation.(representation, params) }
  end

  def eager_loaded_representations
    representations.to_active_relation.includes(:exercise, :track, :feedback_author, :feedback_editor)
  end

  class SerializeRepresentation
    include Mandate

    initialize_with :representation, :params

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
        feedback_author: { handle: representation.feedback_author&.handle },
        feedback_editor: { handle: representation.feedback_editor&.handle },
        feedback_added_at: representation.feedback_added_at,
        feedback_html: representation.feedback_html,
        last_submitted_at: representation.last_submitted_at,
        links: {
          edit: Exercism::Routes.edit_mentoring_automation_path(representation, source: params)
        }
      }
    end
  end
end
