class Submission
  class Representation
    class Create
      include Mandate

      initialize_with :submission, :tooling_job, :ast_digest

      def call
        submission.create_submission_representation!(
          tooling_job_id: tooling_job.id,
          ops_status: tooling_job.execution_status.to_i,
          ast_digest:
        )
      end
    end
  end
end
