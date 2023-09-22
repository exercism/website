class API::Solutions::SubmissionTestRunsController < API::BaseController
  def show
    submission = Submission.find_by!(uuid: params[:submission_uuid])

    return render_403(:submission_not_accessible) unless submission.viewable_by?(current_user)

    test_run = SerializeSubmissionTestRun.(submission.test_run)

    render json: {
      test_run:,
      test_runner: {
        average_test_duration: submission.track.average_test_duration,
        status: {
          exercise: submission.exercise.has_test_runner,
          track: submission.track.has_test_runner
        }
      }
    }
  end

  def cancel
    submission = Submission.find_by(uuid: params[:submission_uuid])

    return render_404(:submission_not_found) unless submission
    return render_403(:submission_not_accessible) unless submission.viewable_by?(current_user)

    ToolingJob::Cancel.(submission.uuid, :test_runner)
    ToolingJob::Cancel.(submission.uuid, :representer)
    ToolingJob::Cancel.(submission.uuid, :analyzer)

    render json: {}
  end
end
