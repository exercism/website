class Exercise
  class Representation
    class CreateOrUpdate
      include Mandate

      initialize_with :submission, :ast, :ast_digest, :mapping, :representer_version, :exercise_version, :last_submitted_at

      def call
        # First cache the old representation
        @old_representation = Exercise::Representation.where(source_submission: submission).last

        @representation = Exercise::Representation.find_create_or_find_by!(
          exercise:, ast_digest:, representer_version:, exercise_version:
        ) do |rep|
          rep.source_submission = submission
          rep.ast = ast
          rep.mapping = mapping
          rep.last_submitted_at = last_submitted_at
        end

        # Now copy the old feedback over if appropriate
        update_feedback!
        update_cache_columns!

        representation
      end

      private
      attr_reader :representation, :old_representation

      delegate :exercise, to: :submission

      def update_feedback!
        return unless old_representation&.has_feedback?

        # Don't overriden new feedback if it's been given (I don't think
        # this can ever occur but it's just a guard in case of some weirdness)
        return if representation.has_feedback?

        # If either of the two version keys have changed then we only want to
        # save this as draft feedback, not actual feedback as we can't guarantee
        # it's definitely appropriate now.
        return add_draft_feedback! if representation.exercise_version != old_representation.exercise_version
        return add_draft_feedback! if representation.representer_version != old_representation.representer_version

        representation.update!(
          feedback_author: old_representation.feedback_author,
          feedback_markdown: old_representation.feedback_markdown,
          feedback_type: old_representation.feedback_type
        )
      end

      def add_draft_feedback!
        representation.update!(
          draft_feedback_markdown: old_representation.feedback_markdown,
          draft_feedback_type: old_representation.feedback_type
        )
      end

      def update_cache_columns!
        representation.update!(last_submitted_at:)
        Exercise::Representation::UpdateNumSubmissions.defer(representation)
      end
    end
  end
end
