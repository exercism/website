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

        begin
          # If any bit of this fails, we should roll back the
          # whole thing and mark as exceptioned
          ActiveRecord::Base.transaction do
            if analysis.ops_errored?
              handle_ops_error!
            else
              handle_completed!
            end
          end
        rescue StandardError
          # Reload the record here to ensure # that it hasn't got
          # in a bad state in the transaction above.
          submission.reload.analysis_exceptioned!
        end

        submission.broadcast!
        submission.iteration&.broadcast!
      end

      private
      attr_reader :tooling_job

      def handle_ops_error!
        submission.analysis_exceptioned!
      end

      def handle_completed!
        submission.analysis_completed!
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
