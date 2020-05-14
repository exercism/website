class Iteration
  class Analysis
    class Process
      include Mandate

      def initialize(iteration_uuid, ops_status, ops_message, analysis)
        @iteration = Iteration.find_by_uuid!(iteration_uuid)
        @ops_status = ops_status.to_i
        @ops_message = ops_message
        @analysis = analysis.is_a?(Hash) ? analysis.symbolize_keys : {}
      end

      def call
        iteration.analyses.create!(
          ops_status: ops_status,
          ops_message: ops_message,
          raw_analysis: analysis
        )
        # TODO: Mark iteration as analyzed and broadcast
        # it here, when we've decided how that works
        #iteration.broadcast!
      end
        
      private
      attr_reader :iteration, :ops_status, :ops_message, :analysis
    end
  end
end

