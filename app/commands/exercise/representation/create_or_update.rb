class Exercise
  class Representation
    class CreateOrUpdate
      include Mandate

      initialize_with :submission, :ast, :ast_digest, :mapping, :last_submitted_at

      def call
        # First cache the old representation
        old_source_submission_representation = Exercise::Representation.where(source_submission: submission).order('id DESC').first

        representation = Exercise::Representation.find_create_or_find_by!(exercise:, ast_digest:) do |rep|
          rep.source_submission = submission
          rep.ast = ast
          rep.mapping = mapping
          rep.last_submitted_at = last_submitted_at
        end

        # Now copy the old feedback over if appropriate
        if old_source_submission_representation&.has_feedback? && !representation.has_feedback?
          representation.update!(
            feedback_author: old_source_submission_representation.feedback_author,
            feedback_markdown: old_source_submission_representation.feedback_markdown,
            feedback_type: old_source_submission_representation.feedback_type
          )
        end

        representation.update!(last_submitted_at:)
        Exercise::Representation::UpdateNumSubmissions.defer(representation)

        representation
      end

      delegate :exercise, to: :submission
    end
  end
end
