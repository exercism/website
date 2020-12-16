module API
  class BugReportsController < BaseController
    def create
      @report = BugReport.create!(bug_report_params.merge(user: current_user))

      render json: { bug_report: @report }
    end

    private
    def bug_report_params
      params.require(:bug_report).permit(:content_markdown)
    end
  end
end
