class Iteration
  class TestRun
    class Process
      include Mandate

      def initialize(iteration_uuid, ops_status, ops_message, results)
        @iteration = Iteration.find_by_uuid!(iteration_uuid)
        @ops_status = ops_status.to_i
        @ops_message = ops_message
        @results = results.is_a?(Hash) ? results.symbolize_keys : {}
      end

      def call
        iteration.test_runs.create!(
          ops_status: ops_status,
          ops_message: ops_message,
          raw_results: results
        )
        # TODO: Mark iteration as tested and broadcast
        # it here, when we've decided how that works
        #iteration.broadcast!
      end
        
      private
      attr_reader :iteration, :ops_status, :ops_message, :results
    end
  end
end
