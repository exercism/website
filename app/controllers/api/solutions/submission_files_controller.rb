class API::Solutions::SubmissionFilesController < API::BaseController
  skip_before_action :authenticate_user!

  def index
    submission = Submission.find_by(uuid: params[:submission_uuid])

    return render_404(:submission_not_found) unless submission
    return render_403(:submission_not_accessible) unless submission.viewable_by?(current_user)

    files = submission.files.map do |file|
      {
        filename: file.filename,
        content: file.content,
        digest: file.digest
      }
    end

    render json: { files: }
  end
end
