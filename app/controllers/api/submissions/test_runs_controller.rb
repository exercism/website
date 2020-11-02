module API
  module Submissions
    class TestRunsController < BaseController
      def show
        submission = current_user.submissions.find_by!(uuid: params[:submission_id])

        test_run = if submission.tests_queued?
                     {
                       id: nil,
                       submission_uuid: submission.uuid,
                       status: :queued,
                       tests: [],
                       message: ""
                     }
                   else
                     SerializeSubmissionTestRun.(submission.test_runs.last)
                   end

        render json: { test_run: test_run }
      end
    end
  end
end
