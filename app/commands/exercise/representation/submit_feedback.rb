class Exercise
  class Representation
    class SubmitFeedback
      include Mandate

      initialize_with :mentor, :representation, :feedback_markdown, :feedback_type

      def call
        # TODO: award reputation to user

        if representation.has_feedback?
          representation.update(feedback_markdown:, feedback_type:, feedback_editor: mentor)
        else
          representation.update(feedback_markdown:, feedback_type:, feedback_author: mentor)
        end
      end
    end
  end
end
