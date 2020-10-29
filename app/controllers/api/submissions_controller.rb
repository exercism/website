module API
  class SubmissionsController < BaseController
    def create
      begin
        solution = Solution.find_by!(uuid: params[:solution_id])
      rescue ActiveRecord::RecordNotFound
        return render_solution_not_found
      end

      return render_solution_not_accessible unless solution.user_id == current_user.id

      formatted_files = submission_params[:files].each_with_object({}) do |file, files|
        files[file[:name]] = file[:contents]
      end

      begin
        # TODO: Change this to be a guard to render an error if files are not present.
        files = if formatted_files.present?
                  Submission::PrepareMappedFiles.(formatted_files.to_h)
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

    private
    def submission_params
      params.permit(files: %i[name contents])
    end
  end
end
