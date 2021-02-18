module API
  module Solutions
    class SubmissionFilesController < BaseController
      def index
        submission = Submission.find_by(uuid: params[:submission_id])

        return render_404(:submission_not_found) unless submission
        return render_403(:submission_not_accessible) unless submission.viewable_by?(current_user)

        files = submission.files.map do |file|
          {
            filename: file.filename,
            content: file.content
          }
        end

        render json: { files: files }
      end
    end
  end
end
