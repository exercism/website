module API
  class SubmissionsController < BaseController
    def create
      begin
        solution = Solution.find_by!(uuid: params[:solution_id])
      rescue ActiveRecord::RecordNotFound
        return render_solution_not_found
      end

      return render_solution_not_accessible unless solution.user_id == current_user.id

      begin
        # TODO: Change this to be a guard to render an error if files are not present.
        files = if params[:files].present?
                  Submission::PrepareMappedFiles.(params[:files].permit!.to_h)
                else
                  []
                end
      rescue SubmissionFileTooLargeError
        return render_error(400, :file_too_large, "#{file.original_filename} is too large")
      end

      begin
        submission = Submission::Create.(solution, files, :api)
      rescue DuplicateSubmissionError
        return render_error(400, :duplicate_submission)
      end

      render json: {
        submission: SerializeSubmission.(submission)
      }, status: :created
    end
  end
end
