class Submission
  class TestRun
    class Process
      include Mandate

      def initialize(tooling_job)
        @tooling_job = tooling_job
      end

      def call
        # This goes in its own transaction. We want
        # to record this whatever happens.
        test_run = submission.test_runs.create!(
          tooling_job_id: tooling_job.id,
          ops_status: tooling_job.execution_status.to_i,
          raw_results: results
        )

        # Then all of the submethods here should
        # action within transaction setting the
        # status to be an error if it fails.
        begin
          if test_run.ops_errored?
            handle_ops_error!
          elsif test_run.passed?
            handle_pass!
          elsif test_run.failed?
            handle_fail!
          elsif test_run.errored?
            handle_error!
          else
            raise "Unknown status"
          end
        rescue StandardError
          submission.tests_exceptioned!
        end

        submission.broadcast!
        test_run.broadcast!
      end

      private
      attr_reader :tooling_job

      def handle_ops_error!
        submission.tests_exceptioned!
      end

      def handle_pass!
        submission.tests_passed!
      end

      def handle_fail!
        submission.tests_failed!
        cancel_other_services!
      end

      def handle_error!
        submission.tests_errored!
        cancel_other_services!
      end

      def cancel_other_services!
        ToolingJob::Cancel.(submission.uuid, :analyzer)
        ToolingJob::Cancel.(submission.uuid, :representer)
      end

      memoize
      def submission
        Submission.find_by!(uuid: tooling_job.submission_uuid)
      end

      memoize
      def results
        res = JSON.parse(tooling_job.execution_output['results.json'])
        res.is_a?(Hash) ? res.symbolize_keys : {}
      rescue StandardError
        {}
      end
    end
  end
end
