class Exercise
  class Representation
    class SubmitFeedback
      include Mandate

      initialize_with :mentor, :representation, :feedback_markdown, :feedback_type

      def call
        if representation.has_feedback?
          representation.update(feedback_markdown:, feedback_type:, feedback_editor: mentor)
          award_reputation_token!(:automation_feedback_editor) unless mentor_is_author?
        else
          representation.update(feedback_markdown:, feedback_type:, feedback_author: mentor)
          award_reputation_token!(:automation_feedback_author)
        end

        representation
      end

      private
      def award_reputation_token!(token_type)
        User::ReputationToken::Create.defer(mentor, token_type, representation:)
      end

      def mentor_is_author?
        mentor == representation.feedback_author
      end
    end
  end
end
