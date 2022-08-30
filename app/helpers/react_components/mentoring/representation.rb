module ReactComponents
  module Mentoring
    class Representation < ReactComponent
      initialize_with :representation, :example_submissions

      def to_s
        super("mentoring-representation", {
          representation: SerializeExerciseRepresentation.(representation),
          examples: example_submissions.map { |submission| SerializeFiles.(submission.files_for_editor) }
        })
      end
    end
  end
end
