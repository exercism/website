class SerializeExerciseRepresentations
  include Mandate

  initialize_with :representations, with_feedback: Mandate::NO_DEFAULT

  def call
    representations.map { |representation| SerializeInstance.(representation, with_feedback) }
  end

  class SerializeInstance
    include Mandate

    initialize_with :representation, :with_feedback

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
        feedback_html: representation.feedback_html,
        last_submitted_at: representation.last_submitted_at,
        links: {
          edit: Exercism::Routes.edit_mentoring_automation_path(representation, with_feedback:)
        }
      }
    end
  end
end
