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
            guidance: {
              representations: Markdown::Parse.(track.mentoring_representations).presence,
              exercise: exercise.mentoring_notes_content,
              track: track.mentoring_notes_content
            },
            scratchpad: {
              is_introducer_hidden: current_user&.introducer_dismissed?("scratchpad"),
              links: {
                markdown: Exercism::Routes.doc_url(:mentoring, "markdown"),
                hide_introducer: Exercism::Routes.hide_api_settings_introducer_path("scratchpad"),
                self: Exercism::Routes.api_scratchpad_page_path(scratchpad.category, scratchpad.title)
              }
            },
            links: {
              success: Exercism::Routes.mentoring_automation_index_path,
              back: back_link
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

        def back_link
          representation.feedback_type.nil? ?
              Exercism::Routes.mentoring_automation_index_path :
              Exercism::Routes.with_feedback_mentoring_automation_index_path
        end

        delegate :track, :exercise, to: :representation
      end
    end
  end
end
