class Iteration
  class Analysis
    class Process
      include Mandate

      def initialize(iteration_uuid, ops_status, ops_message, analysis_data)
        @iteration = Iteration.find_by_uuid!(iteration_uuid)
        @ops_status = ops_status.to_i
        @ops_message = ops_message
        @analysis_data = analysis_data.is_a?(Hash) ? analysis_data.symbolize_keys : {}
      end

      def call
        analysis = iteration.analyses.create!(
          ops_status: ops_status,
          ops_message: ops_message,
          raw_analysis: analysis_data
        )

        # Then all of the submethods here should
        # action within transaction setting the 
        # status to be an error if it fails.
        begin
          case
          when analysis.ops_errored?
            handle_ops_error!
          when analysis.approved?
            handle_approved!
          when analysis.disapproved?
            handle_disapproved!
          else 
            raise "Unknown status"
          end
        rescue
          iteration.analysis_exceptioned!
        end

        # TODO: Mark iteration as analyzed and broadcast
        # it here, when we've decided how that works
        #iteration.broadcast!
      end
        
      private
      attr_reader :iteration, :ops_status, :ops_message, :analysis_data

      def handle_ops_error!
        iteration.analysis_exceptioned!
      end

      def handle_approved!
        iteration.analysis_approved!
      end

      def handle_disapproved!
        iteration.analysis_disapproved!
      end
    end
  end
end

