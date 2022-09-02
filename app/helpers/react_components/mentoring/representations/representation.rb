module ReactComponents
  module Mentoring
    module Representations
      class Representation < ReactComponent
        initialize_with :mentor, :representation, :example_submissions

        def to_s
          super("mentoring-representation", {
            representation: SerializeExerciseRepresentation.(representation),
            examples: examples_data,
            mentor: mentor_data,
            rules: {
              global_html: Markdown::Parse.(I18n.t("mentoring.rules.global")),
              track_html: Markdown::Parse.(track.representer_mentoring),
              exercise_html: exercise.mentoring_notes.content
            },
            links: {
              success: Exercism::Routes.mentoring_automation_index_url,
              back: representation.feedback_type.nil? ?
                Exercism::Routes.mentoring_automation_index_path :
                Exercism::Routes.with_feedback_mentoring_automation_index_path
            }
          })
        end

        def examples_data
          example_submissions.map do |submission|
            {
              files: SerializeFiles.(submission.files_for_editor),
              instructions: Markdown::Parse.(submission.solution.instructions),
              tests: submission.solution.tests
            }
          end
        end

        def mentor_data
          {
            name: mentor.name,
            handle: mentor.handle,
            avatar_url: mentor.avatar_url
          }
        end

        delegate :track, :exercise, to: :representation
      end
    end
  end
end
