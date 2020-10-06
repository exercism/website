class Submission
  class Representation
    class Process
      include Mandate

      def initialize(submission_uuid, ops_status, ops_message, ast, mapping)
        @submission = Submission.find_by!(uuid: submission_uuid)
        @ops_status = ops_status.to_i
        @ops_message = ops_message
        @ast = ast
        @mapping = mapping
      end

      def call
        # Firstly, create a record for debugging and to give
        # us some basis of the next set of decisions etc.
        @submission_representation = Submission::Representation.create!(
          submission: submission,
          ops_status: ops_status,
          ops_message: ops_message,
          ast: ast
        )

        return handle_ops_error! if submission_representation.ops_errored?

        # Now we need to check to see if we already have an exercise
        # representation for this submission and version
        @exercise_representation = Exercise::Representation.create_or_find_by!(
          exercise: submission.exercise,
          exercise_version: exercise_version,
          ast_digest: submission_representation.ast_digest
        ) do |rep|
          rep.source_submission = submission
          rep.mapping = mapping
          rep.ast = ast
        end

        # Then all of the submethods here should
        # action within transaction setting the
        # status to be an error if it fails.
        begin
          if exercise_representation.approve?
            handle_approve!
          elsif exercise_representation.disapprove?
            handle_disapprove!
          else
            handle_pending!
          end
        rescue StandardError
          submission.analysis_exceptioned!
        end

        submission.broadcast!
      end
      attr_reader :submission, :ops_status, :ops_message, :ast, :mapping
      attr_reader :submission_representation, :exercise_representation

      private
      def exercise_version
        submission.exercise_version.to_i # to_i returns everything up to the dot
      end

      def handle_ops_error!
        submission.representation_exceptioned!
      end

      def handle_approve!
        submission.representation_approved!
        create_discussion_post!
      end

      def handle_disapprove!
        submission.representation_disapproved!
        create_discussion_post!
      end

      def handle_pending!
        submission.representation_inconclusive!
      end

      def create_discussion_post!
        return unless exercise_representation.has_feedback?

        Submission::DiscussionPost::CreateFromRepresentation.(
          submission,
          submission_representation,
          exercise_representation
        )
      end
    end
  end
end
