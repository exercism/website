module API
  module Submissions
    class TestRunsController < BaseController
      def show
        submission = current_user.submissions.find_by!(uuid: params[:submission_id])

        test_run = SerializeSubmissionTestRun.(submission.test_run)

        render json: { test_run: test_run }
      end
    end
  end
end
