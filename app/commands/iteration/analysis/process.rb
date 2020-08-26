class Iteration
  class Analysis
    class Process
      include Mandate

      def initialize(iteration_uuid, ops_status, ops_message, data)
        @iteration = Iteration.find_by!(uuid: iteration_uuid)
        @ops_status = ops_status.to_i
        @ops_message = ops_message
        @data = data.is_a?(Hash) ? data.symbolize_keys : {}
      end

      def call
        # Firstly create a record for debugging and to give
        # us some basis of the next set of decisions etc.
        analysis = iteration.analyses.create!(
          ops_status: ops_status,
          ops_message: ops_message,
          data: data
        )

        # Then all of the submethods here should
        # action within transaction setting the
        # status to be an error if it fails.
        begin
          if analysis.ops_errored?
            handle_ops_error!
          elsif analysis.approved?
            handle_approved!
          elsif analysis.disapproved?
            handle_disapproved!
          elsif analysis.inconclusive?
            handle_inconclusive!
          else
            raise "Unknown status"
          end
        rescue StandardError
          iteration.analysis_exceptioned!
        end

        # TODO: Mark iteration as analyzed and broadcast
        # it here, when we've decided how that works
        iteration.broadcast!
      end

      private
      attr_reader :iteration, :ops_status, :ops_message, :data

      def handle_ops_error!
        iteration.analysis_exceptioned!
      end

      def handle_approved!
        iteration.analysis_approved!
      end

      def handle_disapproved!
        iteration.analysis_disapproved!
      end

      def handle_inconclusive!
        iteration.analysis_inconclusive!
      end
    end
  end
end
