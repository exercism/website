class Submission
  class Representation
    class Process
      include Mandate

      def initialize(tooling_job)
        @tooling_job = tooling_job
      end

      def call
        create_submission_representation!

        # If we had an error then handle the error and leave
        return handle_ops_error! if submission_representation.ops_errored?

        # Otherwise, lets retrieve or create the version of this.
        create_exercise_representation!

        begin
          handle_generated!
        rescue StandardError
          # Reload the record here to ensure
          # that it hasn't got in a bad state in the
          # transaction above.
          submission.reload.representation_exceptioned!
        end

        submission.broadcast!
        submission.iteration&.broadcast!
      end

      attr_reader :tooling_job, :exercise_representation, :submission_representation

      def create_submission_representation!
        @submission_representation = submission.create_submission_representation!(
          tooling_job_id: tooling_job.id,
          ops_status: tooling_job.execution_status.to_i,
          ast_digest: ast_digest
        )
      end

      def create_exercise_representation!
        @exercise_representation = Exercise::Representation.create_or_find_by!(
          exercise: submission.exercise,
          ast_digest: ast_digest
        ) do |rep|
          rep.source_submission = submission
          rep.ast = ast
          rep.mapping = mapping
        end
      end

      def handle_ops_error!
        submission.representation_exceptioned!
      end

      def handle_generated!
        submission.representation_generated!
        create_notification!
      end

      def create_notification!
        return unless exercise_representation.has_feedback?

        # TODO: Create notification about the fact there
        # is a piece of automated feedback
      end

      memoize
      def ops_status
        tooling_job.execution_status.to_i
      end

      memoize
      def ops_success?
        ops_status == 200
      end

      memoize
      def ast_digest
        Submission::Representation.digest_ast(ast)
      end

      memoize
      def submission
        Submission.find_by!(uuid: tooling_job.submission_uuid)
      end

      memoize
      def ast
        tooling_job.execution_output['representation.txt']
      rescue StandardError
        nil
      end

      memoize
      def mapping
        res = JSON.parse(tooling_job.execution_output['mapping.json'])
        res.is_a?(Hash) ? res.symbolize_keys : {}
      rescue StandardError
        {}
      end
    end
  end
end
