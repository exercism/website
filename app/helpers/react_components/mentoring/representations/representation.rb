module ReactComponents
  module Mentoring
    module Representations
      class Representation < ReactComponent
        initialize_with :mentor, :representation, :example_submissions, :source_params

        def to_s
          super("mentoring-representation", {
            representation: SerializeExerciseRepresentation.(representation),
            examples: examples_data,
            mentor: mentor_data,
            mentor_solution:,
            analyzer_feedback: representation.analyzer_feedback,
            guidance: {
              representations: Markdown::Parse.(track.mentoring_representations).presence,
              exercise: exercise.mentoring_notes_content,
              track: track.mentoring_notes_content,
              exemplar_files: SerializeExemplarFiles.(exercise.exemplar_files),
              links: {
                improve_exercise_guidance: exercise.mentoring_notes_edit_url,
                improve_track_guidance: track.mentoring_notes_edit_url,
                improve_representer_guidance: "https://github.com/exercism/#{track.slug}/new/main?filename=exercises/shared/.docs/representations.md",
                representation_feedback_guide: Exercism::Routes.doc_url(:mentoring, "how-to-give-feedback-on-representations")
              }
            },
            scratchpad: {
              is_introducer_hidden: true,
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
              files: SerializeFilesWithMetadata.(submission.files_for_editor),
              instructions: Markdown::Parse.(submission.solution.instructions),
              test_files: SerializeFiles.(submission.solution.test_files)
            }
          end
        end

        def mentor_data
          {
            name: mentor.name,
            handle: mentor.handle,
            flair: mentor.flair,
            avatar_url: mentor.avatar_url
          }
        end

        def back_link
          representation.feedback_type.nil? ?
              Exercism::Routes.mentoring_automation_index_path(**source_params) :
              Exercism::Routes.with_feedback_mentoring_automation_index_path(**source_params)
        end

        memoize
        def scratchpad
          ScratchpadPage.new(about: exercise)
        end

        def mentor_solution
          ms = ::Solution.for(current_user, exercise)
          ms ? SerializeCommunitySolution.(ms) : nil
        end

        delegate :track, :exercise, to: :representation

        class SerializeExemplarFiles
          include Mandate

          initialize_with :files

          def call
            files.map do |filename, content|
              {
                filename: filename.gsub(%r{^\.meta/}, ''),
                content:
              }
            end
          end
        end
      end
    end
  end
end
