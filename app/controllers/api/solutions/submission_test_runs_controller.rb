module API
  module Solutions
    class SubmissionTestRunsController < BaseController
      def show
        submission = Submission.find_by!(uuid: params[:submission_id])

        return render_403(:submission_not_accessible) unless submission.viewable_by?(current_user)

        test_run = SerializeSubmissionTestRun.(submission.test_run)

        render json: { test_run: test_run }
      end
    end
  end
end
