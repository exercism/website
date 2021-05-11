module API
  class Solutions::SubmissionsController < BaseController
    def create
      begin
        solution = Solution.find_by!(uuid: params[:solution_id])
      rescue ActiveRecord::RecordNotFound
        return render_solution_not_found
      end

      return render_solution_not_accessible unless solution.user_id == current_user.id

      files = submission_params[:files].map(&:to_h).map(&:symbolize_keys)

      # TODO: Move this check into a guard service along with the CLI, which raises and
      # rescues SubmissionFileTooLargeError exceptions
      return render_error(400, :file_too_large) if files.any? { |file| file[:content].size > 1.megabyte }

      # TODO: Allow rerunning of tests if previous submission was an error / ops error / timeout
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
      params.permit(files: %i[filename content])
    end
  end
end
