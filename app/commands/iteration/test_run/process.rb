class Iteration
  class TestRun
    class Process
      include Mandate

      def initialize(iteration_uuid, ops_status, ops_message, results)
        @iteration = Iteration.find_by!(uuid: iteration_uuid)
        @ops_status = ops_status.to_i
        @ops_message = ops_message
        @results = results.is_a?(Hash) ? results.symbolize_keys : {}
      end

      def call
        # This goes in its own transaction. We want
        # to record this whatever happens.
        test_run = iteration.test_runs.create!(
          ops_status: ops_status,
          ops_message: ops_message,
          raw_results: results,
          status: "TODO"
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
          iteration.tests_exceptioned!
        end

        # TODO: Mark iteration as tested and broadcast
        # it here, when we've decided how that works
        iteration.broadcast!
      end

      private
      attr_reader :iteration, :ops_status, :ops_message, :results

      def handle_ops_error!
        iteration.tests_exceptioned!
      end

      def handle_pass!
        iteration.tests_passed!
      end

      def handle_fail!
        iteration.tests_failed!
        cancel_other_services!
      end

      def handle_error!
        iteration.tests_errored!
        cancel_other_services!
      end

      def cancel_other_services!
        Iteration::Analysis::Cancel.(iteration.uuid)
        Iteration::Representation::Cancel.(iteration.uuid)
      end
    end
  end
end
