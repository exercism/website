# TODO: This whole class needs tests
# TODO: Rename to ProblemReports
class API::BugReportsController < API::BaseController
  def create
    begin
      exercise_slug = params[:bug_report][:exercise_slug]
      track_slug = params[:bug_report][:track_slug]
      if track_slug.present? && exercise_slug.present?
        exercise = Exercise.joins(:track).where('tracks.slug': track_slug).find(exercise_slug)
      end
    rescue StandardError
      # Don't let this being wrong break the bug report
    end

    @report = ProblemReport.create!(
      bug_report_params.merge(
        type: :bug,
        user: current_user,
        about: exercise
      )
    )

    render json: { bug_report: @report }
  end

  private
  def bug_report_params
    params.require(:bug_report).permit(:content_markdown)
  end
end
