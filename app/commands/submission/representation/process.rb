class Submission
  class Representation
    class Process
      include Mandate

      initialize_with :tooling_job

      def call
        create_submission_representation!

        begin
          # If we had an error then handle the error and leave
          return handle_ops_error! if submission_representation.ops_errored?

          # Otherwise, lets retrieve or create the version of this.
          create_exercise_representation!

          # If any bit of this fails, we should roll back the
          # whole thing and mark as exceptioned
          ActiveRecord::Base.transaction do
            handle_generated!
          end
        rescue StandardError
          raise unless Rails.env.production?

          # Reload the record here to ensure # that it hasn't got
          # in a bad state in the transaction above.
          submission.reload.representation_exceptioned!
        end

        submission.broadcast!
        submission.iteration&.broadcast!
      end

      attr_reader :exercise_representation, :submission_representation

      def create_submission_representation!
        raise unless ast_digest

        @submission_representation = Submission::Representation::Create.(
          submission, tooling_job, ast_digest
        )
      end

      def create_exercise_representation!
        @exercise_representation = Exercise::Representation::CreateOrUpdate.(
          submission,
          ast, ast_digest, mapping,
          representer_version, exercise_version,
          @submission_representation.created_at
        )
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

        # TODO: (Required) Create notification about the fact there
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

      def representer_version
        # TODO: This should come back from the results
        # Do we have a new file call output.json that can
        # have this key set in it? I don't think there's currently
        # a natural place for this.
        1
      end

      def exercise_version
        submission.solution.git_exercise.representer_version
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
