class Submission
  class Analysis
    class Process
      include Mandate

      def initialize(submission_uuid, ops_status, data)
        @submission = Submission.find_by!(uuid: submission_uuid)
        @ops_status = ops_status.to_i
        @data = data.is_a?(Hash) ? data.symbolize_keys : {}
      end

      def call
        # Firstly create a record for debugging and to give
        # us some basis of the next set of decisions etc.
        analysis = submission.create_analysis!(
          ops_status: ops_status,
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
          submission.analysis_exceptioned!
        end

        submission.broadcast!
      end

      private
      attr_reader :submission, :ops_status, :data

      def handle_ops_error!
        submission.analysis_exceptioned!
      end

      def handle_approved!
        submission.analysis_approved!
      end

      def handle_disapproved!
        submission.analysis_disapproved!
      end

      def handle_inconclusive!
        submission.analysis_inconclusive!
      end
    end
  end
end
