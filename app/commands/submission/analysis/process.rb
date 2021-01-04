class Submission
  class Analysis
    class Process
      include Mandate

      def initialize(tooling_job)
        @tooling_job = tooling_job
      end

      def call
        # Firstly create a record for debugging and to give
        # us some basis of the next set of decisions etc.
        analysis = submission.create_analysis!(
          tooling_job_id: tooling_job.id,
          ops_status: tooling_job.execution_status.to_i,
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
      attr_reader :tooling_job

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

      memoize
      def submission
        Submission.find_by!(uuid: tooling_job.submission_uuid)
      end

      memoize
      def data
        res = JSON.parse(tooling_job.execution_output['analysis.json'])
        res.is_a?(Hash) ? res.symbolize_keys : {}
      rescue StandardError
        {}
      end
    end
  end
end
