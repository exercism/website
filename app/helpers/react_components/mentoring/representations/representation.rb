module ReactComponents
  module Mentoring
    module Representations
      class Representation < ReactComponent
        initialize_with :mentor, :representation, :example_submissions

        def to_s
          super("mentoring-representation", {
            representation: representation_data,
            examples: examples_data,
            mentor: mentor_data
          })
        end

        def representation_data
          SerializeExerciseRepresentation.(representation)
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
      end
    end
  end
end
