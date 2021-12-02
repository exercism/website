class Submission
  class TestRun
    class Process
      include Mandate

      initialize_with :tooling_job

      def call
        # This goes in its own transaction. We want
        # to record this whatever happens.
        test_run = submission.create_test_run!(
          tooling_job_id: tooling_job.id,
          ops_status: tooling_job.execution_status.to_i,
          raw_results: results,
          git_sha: git_sha
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
          update_status!(:exceptioned)
        end

        broadcast!(test_run)
      end

      private
      def handle_ops_error!
        update_status!(:exceptioned)
      end

      def handle_pass!
        update_status!(:passed)
      end

      def handle_fail!
        update_status!(:failed)
        cancel_other_services!
      end

      def handle_error!
        update_status!(:errored)
        cancel_other_services!
      end

      def cancel_other_services!
        return unless normal_test_run?

        ToolingJob::Cancel.(submission.uuid, :analyzer)
        ToolingJob::Cancel.(submission.uuid, :representer)
      end

      def update_status!(status)
        if solution_test_run?
          update_solution_status!(status)
        else
          update_submission_status!(status)
        end
      end

      def update_submission_status!(status)
        submission.with_lock do
          return if submission.tests_cancelled?

          submission.send("tests_#{status}!")
        end
      end

      def update_solution_status!(status)
        return unless submission.exercise.git_sha == git_sha

        submission.solution.send("published_iteration_head_tests_status_#{status}!")
      end

      def broadcast!(test_run)
        return unless submission_test_run?

        # Work through and process the test run
        # then before broadcasting, check whether it's been
        # cancelled, and update it if so.
        # This whole bit is very racey so the order is very
        # important to consider.
        if submission.tests_cancelled?
          test_run.update!(status: "cancelled")
          return
        end

        submission.broadcast!
        submission.iteration&.broadcast!
        test_run.broadcast!
      end

      memoize
      def results
        res = JSON.parse(tooling_job.execution_output['results.json'], allow_invalid_unicode: true)
        res.is_a?(Hash) ? res.symbolize_keys : {}
      rescue StandardError
        {}
      end

      memoize
      def submission
        Submission.find_by!(uuid: tooling_job.submission_uuid)
      end

      memoize
      def solution_test_run?
        test_run_type == :solution
      end

      # This should be "anything else" rather than a specific
      # check as legacy jobs don't have this field
      memoize
      def submission_test_run?
        !solution_test_run?
      end

      memoize
      def test_run_type
        tooling_job.test_run_type.to_sym
      rescue NoMethodError
        :submission
      end

      def git_sha
        tooling_job.source["exercise_git_sha"]
      end
    end
  end
end
